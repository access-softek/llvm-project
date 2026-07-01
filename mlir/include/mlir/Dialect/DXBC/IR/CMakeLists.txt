set(LLVM_TARGET_DEFINITIONS DXBCOps.td)
add_mlir_dialect(DXBCOps dxbc)
add_mlir_doc(DXBCOps DXBCDialect Dialects/ -gen-dialect-doc)
