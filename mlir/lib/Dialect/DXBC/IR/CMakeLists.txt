add_mlir_dialect_library(MLIRDXBCDialect
  DXBC.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Dialect/DXBC

  DEPENDS
  MLIRDXBCOpsIncGen

  LINK_LIBS PUBLIC
  MLIRDialect
  MLIRIR
  )
