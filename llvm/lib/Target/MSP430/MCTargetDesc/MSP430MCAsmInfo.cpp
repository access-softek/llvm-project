//===-- MSP430MCAsmInfo.cpp - MSP430 asm properties -----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the declarations of the MSP430MCAsmInfo properties.
//
//===----------------------------------------------------------------------===//

#include "MSP430MCAsmInfo.h"
using namespace llvm;

void MSP430MCAsmInfo::anchor() { }

MSP430MCAsmInfo::MSP430MCAsmInfo(const Triple &TT) {
  // For the purpose of compatibility with MSP430-GCC binaries, the 16-bit pointer
  // will be stored in 32-bit fields within DWARF information.
  CodePointerSize = 4;
  CalleeSaveStackSlotSize = 2;

  CommentString = ";";
  SeparatorString = "{";

  AlignmentIsInBytes = false;
  UsesELFSectionDirectiveForBSS = true;

  SupportsDebugInformation = true;

  ExceptionsType = ExceptionHandling::DwarfCFI;
}
