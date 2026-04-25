set(LLVM_TARGET_DEFINITIONS DXBCOps.td)
mlir_tablegen(DXBCOpsEnums.h.inc -gen-enum-decls)
mlir_tablegen(DXBCOpsEnums.cpp.inc -gen-enum-defs)
mlir_tablegen(DXBCOpsAttributes.h.inc -gen-attrdef-decls
              -attrdefs-dialect=dxbc)
mlir_tablegen(DXBCOpsAttributes.cpp.inc -gen-attrdef-defs
              -attrdefs-dialect=dxbc)
add_mlir_dialect(DXBCOps dxbc)
add_mlir_doc(DXBCOps DXBCDialect Dialects/ -gen-dialect-doc)
