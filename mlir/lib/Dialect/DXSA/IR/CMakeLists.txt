add_mlir_dialect_library(MLIRDXSADialect
  DXSA.cpp
  DXSAOperand.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/DXSA

  DEPENDS
  MLIRDXSAOpsIncGen

  LINK_LIBS PUBLIC
  MLIRDialect
  MLIRIR
  )
