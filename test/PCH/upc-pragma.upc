// Test this without pch.
// RUN: %clang_cc1 -include %S/upc-pragma.h -emit-llvm -o - %s | FileCheck %s

// Test with pch.
// RUN: %clang_cc1 -x upc-header -emit-pch -o %t %S/upc-pragma.h
// RUN: %clang_cc1 -include-pch %t -emit-llvm -o - %s | FileCheck %s

// CHECK: %8 = call i32 @__getssi2(i64 %7)

int test(shared int * ptr) {
  return *ptr;
}
