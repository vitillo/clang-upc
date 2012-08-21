// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - | FileCheck %s

void f(shared int * ptr, int);

void test_upcforall_int(shared int * ptr, int n) {
  upc_forall(int i = 0; i < n; ++i; i) {
    f(ptr, i);
  }
}
// CHECK: test_upcforall_int
// CHECK: %0 = load i32* @__upc_forall_depth
// CHECK-NEXT: %upc_forall.inc_depth = add nuw i32 %0, 1
// CHECK-NEXT: store i32 %upc_forall.inc_depth, i32* @__upc_forall_depth

// CHECK: upcforall.cond.cleanup:
// CHECK-NEXT: store i32 2, i32* %cleanup.dest.slot
// CHECK-NEXT: store i32 %0, i32* @__upc_forall_depth

// CHECK: upc_forall.filter:
// CHECK-NEXT: %3 = load i32* %i, align 4
// CHECK-NEXT: %4 = load i32* @THREADS
// CHECK-NEXT: %5 = srem i32 %3, %4
// CHECK-NEXT: %6 = add i32 %5, %4
// CHECK-NEXT: %7 = icmp slt i32 %5, 0
// CHECK-NEXT: %8 = select i1 %7, i32 %6, i32 %5
// CHECK-NEXT: %9 = load i32* @MYTHREAD
// CHECK-NEXT: %10 = icmp eq i32 %8, %9
// CHECK-NEXT: %11 = icmp ugt i32 %0, 0
// CHECK-NEXT: %12 = or i1 %11, %10
// CHECK-NEXT: br i1 %12, label %upc_forall.body, label %upc_forall.inc
