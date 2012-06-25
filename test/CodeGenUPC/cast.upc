// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - | FileCheck %s

shared [2] int * testzerophase(shared [3] int * ptr) {
  return (shared [2] int *)ptr;
}
// CHECK: testzerophase
// CHECK: %1 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK-NEXT: %2 = and i64 %1, 17179869183
// CHECK-NEXT: %3 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK-NEXT: %4 = lshr i64 %3, 34
// CHECK-NEXT: %5 = and i64 %4, 1023
// CHECK-NEXT: %6 = shl i64 %5, 34
// CHECK-NEXT: %7 = or i64 %6, %2
// CHECK-NEXT: %8 = or i64 0, %7
// CHECK-NEXT: %9 = insertvalue %__upc_shared_pointer_type undef, i64 %8, 0

shared int *testnull(void) { return 0; }
// CHECK: testnull
// CHECK: store %__upc_shared_pointer_type zeroinitializer, %__upc_shared_pointer_type* %retval
