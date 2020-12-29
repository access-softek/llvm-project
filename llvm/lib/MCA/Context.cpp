//===---------------------------- Context.cpp -------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
///
/// This file defines a class for holding ownership of various simulated
/// hardware units.  A Context also provides a utility routine for constructing
/// a default out-of-order pipeline with fetch, dispatch, execute, and retire
/// stages.
///
//===----------------------------------------------------------------------===//

#include "llvm/MCA/Context.h"
#include "llvm/MCA/HardwareUnits/RegisterFile.h"
#include "llvm/MCA/HardwareUnits/RetireControlUnit.h"
#include "llvm/MCA/HardwareUnits/Scheduler.h"
#include "llvm/MCA/Stages/DispatchStage.h"
#include "llvm/MCA/Stages/EntryStage.h"
#include "llvm/MCA/Stages/ExecuteStage.h"
#include "llvm/MCA/Stages/InOrderIssueStage.h"
#include "llvm/MCA/Stages/MicroOpQueueStage.h"
#include "llvm/MCA/Stages/RetireStage.h"

namespace llvm {
namespace mca {

std::unique_ptr<Pipeline>
Context::createDefaultPipeline(const PipelineOptions &Opts, SourceMgr &SrcMgr) {
  const MCSchedModel &SM = STI.getSchedModel();

  // Create the hardware units defining the backend.
  std::unique_ptr<RetireControlUnit> RCU;
  if (SM.isOutOfOrder())
    RCU = std::make_unique<RetireControlUnit>(SM);

  auto PRF = std::make_unique<RegisterFile>(SM, MRI, Opts.RegisterFileSize);
  auto LSU = std::make_unique<LSUnit>(SM, Opts.LoadQueueSize,
                                       Opts.StoreQueueSize, Opts.AssumeNoAlias);
  auto HWS = std::make_unique<Scheduler>(SM, *LSU);

  // Build the pipeline.
  auto StagePipeline = std::make_unique<Pipeline>();
  StagePipeline->appendStage(std::make_unique<EntryStage>(SrcMgr));
  if (SM.isOutOfOrder()) {
    if (Opts.MicroOpQueueSize) {
      StagePipeline->appendStage(std::make_unique<MicroOpQueueStage>(
          Opts.MicroOpQueueSize, Opts.DecodersThroughput));
    }
    StagePipeline->appendStage(std::make_unique<DispatchStage>(
        STI, MRI, Opts.DispatchWidth, RCU.get(), *PRF));
    StagePipeline->appendStage(
        std::make_unique<ExecuteStage>(*HWS, Opts.EnableBottleneckAnalysis));
  } else {
    StagePipeline->appendStage(
        std::make_unique<InOrderIssueStage>(*PRF, SM, STI));
  }
  StagePipeline->appendStage(
      std::make_unique<RetireStage>(RCU.get(), *PRF, *LSU));

  // Pass the ownership of all the hardware units to this Context.
  addHardwareUnit(std::move(RCU));
  addHardwareUnit(std::move(PRF));
  addHardwareUnit(std::move(LSU));
  addHardwareUnit(std::move(HWS));

  return StagePipeline;
}

} // namespace mca
} // namespace llvm
