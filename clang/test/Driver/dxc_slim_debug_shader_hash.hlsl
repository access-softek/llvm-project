// Shader hash should be the same when /Zss is used with either /Zs or /Zi, with PDB output on.
// RUN: %clang_dxc -Tlib_6_7 %s /Fd %t.pdb /Fo %t.zi.zss.dxbc /Zss /Zi
// RUN: %clang_dxc -Tlib_6_7 %s /Fd %t.pdb /Fo %t.zs.zss.dxbc /Zss /Zs
// RUN: %clang_dxc -Tlib_6_7 %s /Fd %t.pdb /Fo %t.zi.dxbc /Zi
// RUN: obj2yaml %t.zi.zss.dxbc -o %t.zi.zss.yaml
// RUN: obj2yaml %t.zs.zss.dxbc -o %t.zs.zss.yaml
// RUN: obj2yaml %t.zi.dxbc -o %t.zi.yaml
// RUN: cat %t.zi.zss.yaml %t.zs.zss.yaml %t.zi.yaml | FileCheck %s --check-prefix=CHECK

// CHECK: --- !dxcontainer
// CHECK: - Name:            HASH
// CHECK:   Hash:
// CHECK:     IncludesSource:  true
// CHECK:     Digest:          [ [[ZSHASH:.+]]
// CHECK: ...
// CHECK: --- !dxcontainer
// CHECK: - Name:            HASH
// CHECK:   Hash:
// CHECK:     IncludesSource:  true
// CHECK:     Digest:          [ [[ZSHASH]]
// CHECK: ...
// CHECK: --- !dxcontainer
// CHECK: - Name:            HASH
// CHECK:   Hash:
// CHECK-NOT: [[ZSHASH]]
// CHECK:     IncludesSource:  false
// CHECK-NOT: [[ZSHASH]]

[numthreads(1, 1, 1)] void main() {}
