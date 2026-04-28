add_mlir_translation_library(MLIRTargetDXSA
  AsmPrinter.cpp
  BinaryParser.cpp
  BinaryWriter.cpp
  TranslateRegistration.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/Target/DXSA

  LINK_LIBS PUBLIC
  MLIRDXSADialect
  MLIRIR
  MLIRSupport
  MLIRTranslateLib
)
