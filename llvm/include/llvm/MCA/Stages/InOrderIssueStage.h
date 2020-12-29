//===---------------------- InOrderIssueStage.h -----------------*- C++ -*-===//
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

#ifndef LLVM_MCA_IN_ORDER_ISSUE_STAGE_H
#define LLVM_MCA_IN_ORDER_ISSUE_STAGE_H

#include "llvm/ADT/SmallVector.h"
#include "llvm/MCA/SourceMgr.h"
#include "llvm/MCA/Stages/Stage.h"

#include <deque>

namespace llvm {
class MCSchedModel;
class MCSubtargetInfo;

namespace mca {
class RegisterFile;
class ResourceManager;

class InOrderIssueStage final : public Stage {
  const MCSchedModel &SM;
  const MCSubtargetInfo &STI;
  RegisterFile &PRF;
  std::unique_ptr<ResourceManager> RM;

  /// Instructions that were issued, but not retired yet. Executed instructions
  /// (with CyclesLeft == 0) are moved to the end of IssuedInst.
  SmallVector<InstRef, 4> IssuedInst;
  /// Number of executed instructions at the end of IssuedInst.
  int NumExecuted;

  /// Instructions that must be issued during the next cycle. If the front
  /// instruction cannot execute due to an unmet register or resource
  /// dependency, the whole queue is stalled for StallCyclesLeft.
  std::deque<InstRef> InstQueue;
  int StallCyclesLeft;

  /// Number of instructions that can be added to InstQueue (dispatched) during
  /// this cycle.
  int Bandwidth;

  InOrderIssueStage(const InOrderIssueStage &Other) = delete;
  InOrderIssueStage &operator=(const InOrderIssueStage &Other) = delete;

  /// If IR has an unmet register or resource dependency, canExecute returns
  /// false. StallCycles is set to the number of cycles left before the
  /// instruction can be issued.
  bool canExecute(const InstRef &IR, int *StallCycles) const;

  /// Issue the instruction, or update StallCycles if IR is stalled.
  Error tryIssue(InstRef &IR, int *StallCycles);
  Error updateIssuedInst();

public:
  InOrderIssueStage(RegisterFile &PRF, const MCSchedModel &SM,
                    const MCSubtargetInfo &STI)
      : SM(SM), STI(STI), PRF(PRF), RM(std::make_unique<ResourceManager>(SM)),
        NumExecuted(0), StallCyclesLeft(0), Bandwidth(0) {}

  bool isAvailable(const InstRef &) const override;
  bool hasWorkToComplete() const override;
  Error execute(InstRef &IR) override;
  Error cycleStart() override;
  Error cycleEnd() override;
};

} // namespace mca
} // namespace llvm

#endif // LLVM_MCA_IN_ORDER_ISSUE_STAGE_H
