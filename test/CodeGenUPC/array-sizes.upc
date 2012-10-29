// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -fupc-threads 3 -o - | FileCheck %s -check-prefix=CHECK-S3
// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -fupc-threads 4 -o - | FileCheck %s -check-prefix=CHECK-S4
// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -fupc-threads 5 -o - | FileCheck %s -check-prefix=CHECK-S5

// trickier static array sizes
shared [2] int a[9];
// CHECK-S3: @a = global [4 x i32] zeroinitializer, section "upc_shared", align 16
// CHECK-S4: @a = global [4 x i32] zeroinitializer, section "upc_shared", align 16
// CHECK-S5: @a = global [2 x i32] zeroinitializer, section "upc_shared", align 16

shared [3] int b[17];
// CHECK-S3: @b = global [6 x i32] zeroinitializer, section "upc_shared", align 16
// CHECK-S4: @b = global [6 x i32] zeroinitializer, section "upc_shared", align 16
// CHECK-S5: @b = global [6 x i32] zeroinitializer, section "upc_shared", align 16

shared [4] int c[31];
// CHECK-S3: @c = global [12 x i32] zeroinitializer, section "upc_shared", align 16
// CHECK-S4: @c = global [8 x i32] zeroinitializer, section "upc_shared", align 16
// CHECK-S5: @c = global [8 x i32] zeroinitializer, section "upc_shared", align 16

