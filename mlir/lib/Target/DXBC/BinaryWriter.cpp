#include "mlir/Dialect/DXBC/IR/DXBC.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Location.h"
#include "mlir/Target/DXBC/BinaryParser.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/DebugLog.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/LogicalResult.h"

#include "d3d12TokenizedProgramFormat.hpp"

#define DEBUG_TYPE "export-dxbc-bin"

using namespace mlir;
using namespace llvm;

namespace mlir::dxbc {
LogicalResult exportModuleToDxsaBinary(ModuleOp source, raw_ostream &output) {
  Region &region = source.getRegion();
  assert(region.hasOneBlock() && "invalid module");
  return failure();
}
} // namespace mlir::dxbc
