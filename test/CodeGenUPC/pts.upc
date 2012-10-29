// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - | FileCheck %s -check-prefix=CHECK-PF
// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - -fupc-pts-vaddr-order=last | FileCheck %s -check-prefix=CHECK-PL
// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - -fupc-pts=struct | FileCheck %s -check-prefix=CHECK-SF
// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - -fupc-pts=struct -fupc-pts-vaddr-order=last | FileCheck %s -check-prefix=CHECK-SL

// Use +, since it has to pick apart the representation
// and put it back together.
shared [3] int * test(shared [3] int * ptr, int i) { return ptr + i; }

// CHECK-PF: and i64 %2, 1048575
// CHECK-PF: %5 = lshr i64 %4, 20
// CHECK-PF: %6 = and i64 %5, 1023
// CHECK-PF: %8 = lshr i64 %7, 30
// CHECK-PF: %22 = udiv i64 %19, 3
// CHECK-PF: %23 = urem i64 %19, 3
// CHECK-PF: %28 = add i64 %8, %27
// CHECK-PF: %29 = shl i64 %22, 20
// CHECK-PF: %30 = or i64 %29, %23
// CHECK-PF: %31 = shl i64 %28, 30
// CHECK-PF: %32 = or i64 %31, %30

// CHECK-PL: %3 = lshr i64 %2, 44
// CHECK-PL: %5 = lshr i64 %4, 34
// CHECK-PL: %6 = and i64 %5, 1023
// CHECK-PL: %8 = and i64 %7, 17179869183
// CHECK-PL: %22 = udiv i64 %19, 3
// CHECK-PL: %23 = urem i64 %19, 3
// CHECK-PL: %28 = add i64 %8, %27
// CHECK-PL: %29 = shl i64 %22, 34
// CHECK-PL: %30 = or i64 %29, %28
// CHECK-PL: %31 = shl i64 %23, 44
// CHECK-PL: %32 = or i64 %31, %30

// CHECK-SF: %5 = extractvalue %__upc_shared_pointer_type %3, 2
// CHECK-SF: %7 = extractvalue %__upc_shared_pointer_type %3, 1
// CHECK-SF: %9 = extractvalue %__upc_shared_pointer_type %3, 0
// CHECK-SF: %23 = udiv i64 %20, 3
// CHECK-SF: %24 = urem i64 %20, 3
// CHECK-SF: %29 = add i64 %9, %28
// CHECK-SF: %30 = trunc i64 %24 to i32
// CHECK-SF: %31 = trunc i64 %23 to i32
// CHECK-SF: %32 = insertvalue %__upc_shared_pointer_type undef, i64 %29, 0
// CHECK-SF: %33 = insertvalue %__upc_shared_pointer_type %32, i32 %31, 1
// CHECK-SF: %34 = insertvalue %__upc_shared_pointer_type %33, i32 %30, 2

// CHECK-SL: %5 = extractvalue %__upc_shared_pointer_type %3, 0
// CHECK-SL: %7 = extractvalue %__upc_shared_pointer_type %3, 1
// CHECK-SL: %9 = extractvalue %__upc_shared_pointer_type %3, 2
// CHECK-SL: %23 = udiv i64 %20, 3
// CHECK-SL: %24 = urem i64 %20, 3
// CHECK-SL: %29 = add i64 %9, %28
// CHECK-SL: %30 = trunc i64 %24 to i32
// CHECK-SL: %31 = trunc i64 %23 to i32
// CHECK-SL: %32 = insertvalue %__upc_shared_pointer_type undef, i32 %30, 0
// CHECK-SL: %33 = insertvalue %__upc_shared_pointer_type %32, i32 %31, 1
// CHECK-SL: %34 = insertvalue %__upc_shared_pointer_type %33, i64 %29, 2
