add_mlir_translation_library(MLIRTargetDXBC
  BinaryParser.cpp
  BinaryWriter.cpp
  TranslateRegistration.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/Target/DXBC

  LINK_LIBS PUBLIC
  MLIRDXBCDialect
  MLIRIR
  MLIRSupport
  MLIRTranslateLib
)
