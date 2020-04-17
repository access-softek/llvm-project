//===-- MSP430CommonEpilogueOptimizer.cpp - Rewrite standard epilogues ----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This is a pass that replaces common epilogue sequences with a single
// 4-byte BR to __mspabi_func_epilog_<N> when appropriate.
//
// This pass is expected to be run after epilogue generation is done and
// is only applicable to MSP430 (not MSP430X).
//
// Technically, sometimes those branches can be emitted just as a 2-byte
// relative JMP instead of an absolute 4-byte BR. Current implementation always
// uses BRs.
//
// See MSP430 Embedded Application Binary Interface, part 3.8
// "__mspabi_func_epilog Helper Functions" for details.
//
//===----------------------------------------------------------------------===//

#include "MSP430.h"
#include "MSP430TargetMachine.h"

#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

using namespace llvm;

#define DEBUG_TYPE "msp430-epilogue-opt"

namespace {

class MSP430CommonEpilogueOptimizer : public MachineFunctionPass {
public:
  static char ID;

  MSP430CommonEpilogueOptimizer() : MachineFunctionPass(ID) {
    initializeMSP430CommonEpilogueOptimizerPass(
        *PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

private:
  const MSP430InstrInfo *TII;

  // Replace instructions in range [EpilogueBegin, EpilogueEnd] with
  // a single branch to LibCallName.
  void replaceKnownEpilogueSequence(MachineBasicBlock &MBB,
                                    MachineInstr *EpilogueBegin,
                                    MachineInstr *EpilogueEnd,
                                    const char *LibCallName) const;

  // Detect a typical epilogue sequence that can be replaced by a single
  // branch to one of __mspabi_func_epilog_<N>.
  // On success, returns the name of an appropriate function and sets
  // EpilogueBegin to the first instruction of the detected epilogue sequence.
  // Returns nullptr when no known epilogue was detected.
  const char *detectKnownEpilogueSequence(MachineInstr &Terminator,
                                          MachineInstr **EpilogueBegin) const;
};

} // end anonymous namespace

char MSP430CommonEpilogueOptimizer::ID = 0;

INITIALIZE_PASS(MSP430CommonEpilogueOptimizer, DEBUG_TYPE,
                "Optimize known epilogue sequences on MSP430", false, false);

// LibCall names arranged so that `N`-th element restores N registers
//
// MSP430 EABI defines standard epilogue helper functions like these:
//
// __mspabi_func_epilog_7: POP R4
// __mspabi_func_epilog_6: POP R5
// __mspabi_func_epilog_5: POP R6
// __mspabi_func_epilog_4: POP R7
// __mspabi_func_epilog_3: POP R8
// __mspabi_func_epilog_2: POP R9
// __mspabi_func_epilog_1: POP R10
//                         RET
//
// These helper functions do not exist on MSP430X
static const char *EpilogueLibCallNames[] = {
    nullptr,
    "__mspabi_func_epilog_1",
    "__mspabi_func_epilog_2",
    "__mspabi_func_epilog_3",
    "__mspabi_func_epilog_4",
    "__mspabi_func_epilog_5",
    "__mspabi_func_epilog_6",
    "__mspabi_func_epilog_7",
};

// Registers to be restored, from the last `POP` instruction to the first
static const unsigned RestoredRegisters[] = {
    MSP430::R10, MSP430::R9, MSP430::R8, MSP430::R7,
    MSP430::R6,  MSP430::R5, MSP430::R4,
};

void MSP430CommonEpilogueOptimizer::replaceKnownEpilogueSequence(
    MachineBasicBlock &MBB, MachineInstr *EpilogueBegin,
    MachineInstr *EpilogueEnd, const char *LibCallName) const {

  const DebugLoc &DL = EpilogueBegin->getDebugLoc();
  BuildMI(MBB, EpilogueBegin, DL, TII->get(MSP430::Bi))
      .addExternalSymbol(LibCallName);

  for (auto *MI = EpilogueBegin; MI != EpilogueEnd;) {
    MachineInstr *InstrToRemove = MI;
    MI = MI->getNextNode();
    InstrToRemove->eraseFromParent();
  }
}

const char *MSP430CommonEpilogueOptimizer::detectKnownEpilogueSequence(
    MachineInstr &Terminator, MachineInstr **EpilogueBegin) const {

  if (Terminator.getOpcode() != MSP430::RET)
    return nullptr;

  unsigned MatchedRegisters = 0;
  for (auto *I = Terminator.getPrevNode();
       I != nullptr && MatchedRegisters < array_lengthof(RestoredRegisters);
       I = I->getPrevNode(), ++MatchedRegisters) {
    if (I->isDebugInstr())
      continue;

    if (I->getOpcode() != MSP430::POP16r ||
        I->getOperand(0).getReg() != RestoredRegisters[MatchedRegisters])
      break;

    // Updated on every successful match
    *EpilogueBegin = I;
  }

  return EpilogueLibCallNames[MatchedRegisters];
}

bool MSP430CommonEpilogueOptimizer::runOnMachineFunction(MachineFunction &MF) {
  TII = static_cast<const MSP430InstrInfo *>(MF.getSubtarget().getInstrInfo());

  bool Modified = false;
  for (auto &MBB : MF) {
    std::vector<MachineInstr *> OriginalTerminators;
    for (auto &Terminator : MBB.terminators())
      OriginalTerminators.push_back(&Terminator);

    for (MachineInstr *Terminator : OriginalTerminators) {
      MachineInstr *KnownEpilogueBegin;

      const char *LibCallName =
          detectKnownEpilogueSequence(*Terminator, &KnownEpilogueBegin);
      if (!LibCallName)
        continue;

      replaceKnownEpilogueSequence(MBB, KnownEpilogueBegin,
                                   Terminator->getNextNode(), LibCallName);
      Modified = true;
    }
  }

  return Modified;
}

FunctionPass *llvm::createMSP430CommonEpilogueOptimizerPass() {
  return new MSP430CommonEpilogueOptimizer();
}
