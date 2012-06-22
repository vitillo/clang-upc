// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - | FileCheck %s

shared int * test(shared int * ptr, int x) { return ptr + x; }
// CHECK: test
// CHECK: %2 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK-NEXT: %3 = lshr i64 %2, 44
// CHECK-NEXT: %4 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK-NEXT: %5 = lshr i64 %4, 34
// CHECK-NEXT: %6 = and i64 %5, 1023
// CHECK-NEXT: %7 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK-NEXT: %8 = and i64 %7, 17179869183
// CHECK-NEXT: %idx.ext = sext i32 %1 to i64
// CHECK-NEXT: %9 = load i32* @THREADS
// CHECK-NEXT: %10 = zext i32 %9 to i64
// CHECK-NEXT: %11 = mul nuw i64 %10, 1
// CHECK-NEXT: %12 = mul nuw i64 %6, 1
// CHECK-NEXT: %13 = add nuw i64 %12, %3
// CHECK-NEXT: %14 = add i64 %13, %idx.ext
// CHECK-NEXT: %15 = srem i64 %14, %11
// CHECK-NEXT: %16 = sdiv i64 %14, %11
// CHECK-NEXT: %17 = icmp slt i64 %16, 0
// CHECK-NEXT: %18 = add i64 %16, %11
// CHECK-NEXT: %19 = select i1 %17, i64 %18, i64 %16
// CHECK-NEXT: %20 = sub i64 %15, 1
// CHECK-NEXT: %21 = select i1 %17, i64 %20, i64 %15
// CHECK-NEXT: %22 = udiv i64 %19, 1
// CHECK-NEXT: %23 = urem i64 %19, 1
// CHECK-NEXT: %24 = mul i64 %21, 1
// CHECK-NEXT: %25 = sub i64 %23, %3
// CHECK-NEXT: %26 = add i64 %25, %24
// CHECK-NEXT: %27 = mul i64 %26, 32
// CHECK-NEXT: %28 = add i64 %8, %27
// CHECK-NEXT: %29 = shl i64 %22, 34
// CHECK-NEXT: %30 = or i64 %29, %28
// CHECK-NEXT: %31 = shl i64 %23, 44
// CHECK-NEXT: %32 = or i64 %31, %30
// CHECK-NEXT: %33 = insertvalue %__upc_shared_pointer_type undef, i64 %32, 0
