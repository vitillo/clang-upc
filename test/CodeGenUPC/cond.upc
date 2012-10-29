// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - | FileCheck %s

int test_if(shared int * ptr) {
  if (ptr)
    return 1;
  else
    return 0;
}
// CHECK: test_if
// CHECK: %1 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK-NEXT: %2 = and i64 %1, 1048575
// CHECK-NEXT: %3 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK-NEXT: %4 = lshr i64 %3, 20
// CHECK-NEXT: %5 = and i64 %4, 1023
// CHECK-NEXT: %6 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK-NEXT: %7 = lshr i64 %6, 30
// CHECK-NEXT: %8 = icmp ne i64 %7, 0
// CHECK-NEXT: %9 = icmp ne i64 %5, 0
// CHECK-NEXT: %10 = icmp ne i64 %2, 0
// CHECK-NEXT: %11 = or i1 %10, %9
// CHECK-NEXT: %12 = or i1 %11, %8
// CHECK-NEXT: br i1 %12, label %if.then, label %if.else
