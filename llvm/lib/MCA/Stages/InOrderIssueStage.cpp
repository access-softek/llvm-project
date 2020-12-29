//===---------------------- InOrderIssueStage.cpp ---------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
///
/// InOrderIssueStage implements an in-order execution pipeline.
///
//===----------------------------------------------------------------------===//

#include "llvm/MCA/Stages/InOrderIssueStage.h"

#include "llvm/MC/MCSchedule.h"
#include "llvm/MCA/HWEventListener.h"
#include "llvm/MCA/HardwareUnits/RegisterFile.h"
#include "llvm/MCA/HardwareUnits/ResourceManager.h"
#include "llvm/MCA/Instruction.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/Error.h"

#include <algorithm>

#define DEBUG_TYPE "llvm-mca"
namespace llvm {
namespace mca {

bool InOrderIssueStage::hasWorkToComplete() const {
  return !IssuedInst.empty() || !InstQueue.empty();
}

bool InOrderIssueStage::isAvailable(const InstRef &IR) const {
  return Bandwidth > 0;
}

bool InOrderIssueStage::canExecute(const InstRef &IR, int *StallCycles) const {
  *StallCycles = 0;

  // Pipeline availability
  if (RM->checkAvailability(IR.getInstruction()->getDesc())) {
    LLVM_DEBUG(dbgs() << "[E] Stall #" << IR << '\n');
    *StallCycles = 1;
  }

  // Register hazard
  SmallVector<WriteRef, 4> Writes;
  bool HasRegHazard = false;
  for (const ReadState &RS : IR.getInstruction()->getUses()) {
    const ReadDescriptor &RD = RS.getDescriptor();
    const MCSchedClassDesc *SC = SM.getSchedClassDesc(RD.SchedClassID);

    PRF.collectWrites(RS, Writes);
    for (const WriteRef &WR : Writes) {
      const WriteState *WS = WR.getWriteState();
      unsigned WriteResID = WS->getWriteResourceID();
      int ReadAdvance = STI.getReadAdvanceCycles(SC, RD.UseIndex, WriteResID);
      assert(WS->getCyclesLeft() != UNKNOWN_CYCLES);
      int CyclesLeft = (int)WS->getCyclesLeft();
      if (CyclesLeft > ReadAdvance) {
        HasRegHazard = true;
        LLVM_DEBUG(dbgs() << "[E] Register hazard: " << WS->getRegisterID()
                          << '\n');
        *StallCycles = std::max(*StallCycles, CyclesLeft - ReadAdvance);
      }
    }
  }

  if (HasRegHazard) {
    // FIXME: add a parameter to HWStallEvent to indicate a number of cycles.
    for (int i = 0; i < *StallCycles; ++i) {
      notifyEvent<HWStallEvent>(
          HWStallEvent(HWStallEvent::RegisterFileStall, IR));
      notifyEvent<HWPressureEvent>(
          HWPressureEvent(HWPressureEvent::REGISTER_DEPS, IR));
    }
  } else if (*StallCycles) {
    assert(*StallCycles == 1 &&
           "Resource dependency should only cause 1 cycle stall");
    notifyEvent<HWStallEvent>(
        HWStallEvent(HWStallEvent::DispatchGroupStall, IR));
    notifyEvent<HWPressureEvent>(
        HWPressureEvent(HWPressureEvent::RESOURCES, IR));
  }

  return *StallCycles == 0;
}

static void addRegisterReadWrite(RegisterFile &PRF, Instruction &IS,
                                 unsigned SourceIndex,
                                 const MCSubtargetInfo &STI,
                                 SmallVectorImpl<unsigned> &UsedRegs) {
  if (IS.isEliminated())
    return;

  for (ReadState &RS : IS.getUses())
    PRF.addRegisterRead(RS, STI);

  for (WriteState &WS : IS.getDefs())
    PRF.addRegisterWrite(WriteRef(SourceIndex, &WS), UsedRegs);
}

static void notifyInstructionExecute(
    const InstRef &IR,
    const SmallVectorImpl<std::pair<ResourceRef, ResourceCycles>> &UsedRes,
    const Stage &S) {

  S.notifyEvent<HWInstructionEvent>(
      HWInstructionEvent(HWInstructionEvent::Ready, IR));
  S.notifyEvent<HWInstructionEvent>(HWInstructionIssuedEvent(IR, UsedRes));

  LLVM_DEBUG(dbgs() << "[E] Issued #" << IR << "\n");
}

static void notifyInstructionDispatch(const InstRef &IR, unsigned Ops,
                                      const SmallVectorImpl<unsigned> &UsedRegs,
                                      const Stage &S) {

  S.notifyEvent<HWInstructionEvent>(
      HWInstructionDispatchedEvent(IR, UsedRegs, Ops));

  LLVM_DEBUG(dbgs() << "[E] Dispatched #" << IR << "\n");
}

llvm::Error InOrderIssueStage::execute(InstRef &IR) {
  Instruction &IS = *IR.getInstruction();

  IS.dispatch(0);
  SmallVector<unsigned, 8> UsedRegs(PRF.getNumRegisterFiles(), 0U);
  // Register file information is not available yet. Dispatch now with "zero"
  // uops, and emit a proper event later.
  notifyInstructionDispatch(IR, /*Ops=*/0, UsedRegs, *this);

  --Bandwidth;
  InstQueue.push_back(IR);

  return llvm::ErrorSuccess();
}

llvm::Error InOrderIssueStage::tryIssue(InstRef &IR, int *StallCycles) {
  Instruction &IS = *IR.getInstruction();
  unsigned SourceIndex = IR.getSourceIndex();

  if (!canExecute(IR, StallCycles)) {
    LLVM_DEBUG(dbgs() << "[E] Stalled #" << IR << " for " << *StallCycles
                      << " cycles\n");
    return llvm::ErrorSuccess();
  }

  SmallVector<unsigned, 4> UsedRegs(PRF.getNumRegisterFiles());
  addRegisterReadWrite(PRF, IS, SourceIndex, STI, UsedRegs);

  // Notify dispatch the second time to update registers used by the
  // instruction.
  notifyInstructionDispatch(IR, IS.getDesc().NumMicroOps, UsedRegs, *this);

  SmallVector<std::pair<ResourceRef, ResourceCycles>, 4> UsedResources;
  RM->issueInstruction(IS.getDesc(), UsedResources);
  IS.execute(SourceIndex);

  // Replace resource masks with valid resource processor IDs.
  for (std::pair<ResourceRef, ResourceCycles> &Use : UsedResources) {
    uint64_t Mask = Use.first.first;
    Use.first.first = RM->resolveResourceMask(Mask);
  }
  notifyInstructionExecute(IR, UsedResources, *this);

  IssuedInst.push_back(IR);
  if (NumExecuted)
    std::iter_swap(IssuedInst.end() - 1, IssuedInst.end() - NumExecuted - 1);

  return llvm::ErrorSuccess();
}

llvm::Error InOrderIssueStage::updateIssuedInst() {
  // Retire instructions executed on the previous cycle
  if (NumExecuted) {
    for (auto I = IssuedInst.end() - NumExecuted, E = IssuedInst.end(); I != E;
         ++I) {
      LLVM_DEBUG(dbgs() << "[E] Retiring #" << *I << " (out of " << NumExecuted
                        << ")\n");
      if (llvm::Error E = moveToTheNextStage(*I))
        return E;
    }
    IssuedInst.resize(IssuedInst.size() - NumExecuted);
    NumExecuted = 0;
  }

  // Update other instructions. Executed instructions will be retired during the
  // next cycle.
  for (auto I = IssuedInst.begin(), E = IssuedInst.end();
       I != (E - NumExecuted);) {
    InstRef &IR = *I;
    Instruction &IS = *IR.getInstruction();

    IS.cycleEvent();
    if (!IS.isExecuted()) {
      LLVM_DEBUG(dbgs() << "[E] Instruction #" << IR
                        << " is still executing\n");
      ++I;
      continue;
    }
    notifyEvent<HWInstructionEvent>(
        HWInstructionEvent(HWInstructionEvent::Executed, IR));

    LLVM_DEBUG(dbgs() << "[E] Instruction #" << IR << " is executed\n");
    ++NumExecuted;
    std::iter_swap(I, E - NumExecuted);
  }

  return llvm::ErrorSuccess();
}

llvm::Error InOrderIssueStage::cycleStart() {
  // Release consumed resources.
  SmallVector<ResourceRef, 4> Freed;
  RM->cycleEvent(Freed);

  if (llvm::Error E = updateIssuedInst())
    return E;

  // Issue instructions scheduled for this cycle
  while (!StallCyclesLeft && !InstQueue.empty()) {
    InstRef &IR = InstQueue.front();
    if (llvm::Error E = tryIssue(IR, &StallCyclesLeft))
      return E;

    // No stall
    if (!StallCyclesLeft)
      InstQueue.pop_front();
  }

  if (!StallCyclesLeft) {
    Bandwidth = SM.IssueWidth;
  } else if (StallCyclesLeft == 1) {
    // The stalled instruction will be ready during the next cycle. Add more
    // instructions if allowed.
    Bandwidth = SM.IssueWidth - InstQueue.size();
    assert(Bandwidth >= 0 && "InstQueue overflow.");
  } else {
    Bandwidth = 0;
  }

  return llvm::ErrorSuccess();
}

llvm::Error InOrderIssueStage::cycleEnd() {
  if (StallCyclesLeft > 0)
    --StallCyclesLeft;
  return llvm::ErrorSuccess();
}

} // namespace mca
} // namespace llvm
