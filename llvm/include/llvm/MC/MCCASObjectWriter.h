//===- llvm/MC/MCCASObjectWriter.h - CAS Object Writer ----------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_MC_MCCASOBJECTWRITER_H
#define LLVM_MC_MCCASOBJECTWRITER_H

#include "llvm/ADT/StringRef.h"
#include "llvm/BinaryFormat/MachO.h"
#include "llvm/CAS/ObjectStore.h"
#include "llvm/MC/MCCASFormatSchemaBase.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSection.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/raw_ostream.h"
#include <cstdint>
#include <memory>

namespace llvm {

class MCCASObjectWriter : public MCObjectWriter {
public:
  using MCObjectWriter::MCObjectWriter;

  /// \name Relocation Data
  /// @{

  struct RelAndSymbol {
    const MCSymbol *Sym;
    const MCFragment *F; // MCCAS
    MachO::any_relocation_info MRE;
    RelAndSymbol(const MCSymbol *Sym,
                 const MCFragment *F, // MCCAS
                 const MachO::any_relocation_info &MRE)
        : Sym(Sym), F(F), // MCCAS
          MRE(MRE) {}
  };

  virtual uint8_t getAddressSize() = 0;
  virtual CASBackendMode getMode() const = 0;
  virtual uint64_t getPaddingSize(const MCAssembler &Asm,
                                  const MCSection *SD) const = 0;
  virtual Triple getTarget() const = 0;
  virtual void resetBuffer() = 0;

  virtual StringRef getContent() const = 0;
  virtual DenseMap<const MCSection *, std::vector<RelAndSymbol>> &
  getRelocations() = 0;
  virtual void prepareObject(MCAssembler &Asm) = 0;
  virtual void writeMachOHeader(MCAssembler &Asm) = 0;
  virtual void writeSectionData(MCAssembler &Asm) = 0;
  virtual void writeRelocations(MCAssembler &Asm) = 0;
  virtual void writeDataInCodeRegion(MCAssembler &Asm) = 0;
  virtual void writeSymbolTable(MCAssembler &Asm) = 0;
};

/// Construct a new CAS object writer instance.
///
/// This routine takes ownership of the target writer subclass.
///
/// \param MOTW - The target specific Mach-O writer subclass.
/// \param TT - The target triple.
/// \param CAS - The ObjectStore instance.
/// \param OS - The stream to write to.
/// \param Schema - The MCCAS schema to use.
/// \param CallBack - The callback to return the result CASID.
/// \returns The constructed object writer.
std::unique_ptr<MCObjectWriter> createMCCASObjectWriter(
    std::unique_ptr<MCObjectTargetWriter> MOTW, const Triple &TT,
    cas::ObjectStore &CAS, CASBackendMode Mode, raw_pwrite_stream &OS,
    bool IsLittleEndian, std::unique_ptr<mccasformats::MCCASSchema> Schema,
    std::optional<MCTargetOptions::ResultCallBackTy> CallBack = std::nullopt,
    raw_pwrite_stream *CasIDOS = nullptr);

} // end namespace llvm

#endif // LLVM_MC_MCCASOBJECTWRITER_H
