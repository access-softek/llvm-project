// RUN: %clang -target x86_64-apple-macos11 -fdepscan=daemon -c \
// RUN:   -x c %s -ccc-print-phases 2>&1 |                      \
// RUN:   FileCheck %s --check-prefix=CHECK-PHASES

// CHECK-PHASES: 0: input
// CHECK-PHASES: 1: depscan, {0}, response-file
// CHECK-PHASES: 2: preprocessor, {1}, cpp-output
// CHECK-PHASES: 3: compiler, {2}, ir
// CHECK-PHASES: 4: backend, {3}, assembler
// CHECK-PHASES: 5: assembler, {4}, object
// CHECK-PHASES: 6: bind-arch, "x86_64", {5}, object

// RUN: %clang -target x86_64-apple-macos11 -fdepscan=daemon -c \
// RUN:   -x c %s -ccc-print-bindings 2>&1 |                    \
// RUN:   FileCheck %s --check-prefix=CHECK-BINDINGS

// CHECK-BINDINGS: # "x86_64-apple-macosx11.0.0" - "clang"
// CHECK-BINDINGS: # "x86_64-apple-macosx11.0.0" - "clang"


// RUN: %clang -target x86_64-apple-macos11 -fdepscan=daemon -c \
// RUN:   -x c %s -### 2>&1 |                                   \
// RUN:   FileCheck %s --check-prefix=CHECK-CMD

// CHECK-CMD: "-cc1depscan" "-fdepscan=daemon" "-o"
// CHECK-CMD: "-cc1" "@

// Both jobs run in process, so the response file stays in memory.
// RUN: %clang -target x86_64-apple-macos11 -fdepscan=daemon -c \
// RUN:   -x c %s -### 2>&1 |                                   \
// RUN:   FileCheck %s --check-prefix=CHECK-IN-MEMORY

// CHECK-IN-MEMORY: "-cc1depscan" "-fdepscan=daemon" "-o" "[[RSP:[^"]*-in-memory-0.rsp]]"
// CHECK-IN-MEMORY: "-cc1" "@[[RSP]]"

// The link job makes the jobs run out of process, so the response file is a
// temporary file on disk.
// RUN: %clang -target x86_64-apple-macos11 -fdepscan=daemon \
// RUN:   -x c %s -### 2>&1 |                                \
// RUN:   FileCheck %s --check-prefix=CHECK-ON-DISK \
// RUN:     --implicit-check-not=-in-memory-

// So does -fno-integrated-cc1 with two jobs.
// RUN: %clang -target x86_64-apple-macos11 -fdepscan=daemon -c \
// RUN:   -fno-integrated-cc1 -x c %s -### 2>&1 |               \
// RUN:   FileCheck %s --check-prefix=CHECK-ON-DISK \
// RUN:     --implicit-check-not=-in-memory-

// CHECK-ON-DISK: "-cc1depscan" "-fdepscan=daemon" "-o" "[[RSP:[^"]*.rsp]]"
// CHECK-ON-DISK: "-cc1" "@[[RSP]]"

// RUN: %clang -target x86_64-apple-macos11 -fdepscan=daemon -c \
// RUN:   -x c %s -save-temps -###

