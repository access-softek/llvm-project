//===- lib/MC/MCCASObjectWriter.cpp - CAS Object Writer -------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/MCCASObjectWriter.h"
#include "llvm/BinaryFormat/MachO.h"
#include "llvm/CAS/ObjectStore.h"
#include "llvm/CASUtil/Utils.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCMachOCASWriter.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include <memory>

using namespace llvm;
using namespace llvm::cas;

#define DEBUG_TYPE "mc"

std::unique_ptr<MCObjectWriter> llvm::createMCCASObjectWriter(
    std::unique_ptr<MCObjectTargetWriter> MOTW, const Triple &TT,
    cas::ObjectStore &CAS, CASBackendMode Mode, raw_pwrite_stream &OS,
    bool IsLittleEndian, std::unique_ptr<mccasformats::MCCASSchema> Schema,
    std::optional<MCTargetOptions::ResultCallBackTy> ResultCallBack,
    raw_pwrite_stream *CasIDOS) {
  return std::make_unique<MachOCASWriter>(
      std::unique_ptr<MCMachObjectTargetWriter>(
          static_cast<MCMachObjectTargetWriter *>(MOTW.release())),
      TT, CAS, Mode, OS, IsLittleEndian, std::move(Schema), ResultCallBack,
      CasIDOS);
}
