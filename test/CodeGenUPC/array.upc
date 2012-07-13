// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -fupc-threads 4 -o - | FileCheck %s

// simple
shared int a[4]; // = {1,2,3,4};

// dynamic initialization of pointer-to-shared
shared int *ptr = a + 2;

int val = a[3];
shared int *pval = &a[3];

int d = ptr - a;
// CHECK: define internal void @__upc_global_var_init3() nounwind section "upc_init"
// CHECK: %1 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK: %2 = and i64 %1, 1048575
// CHECK: %3 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK: %4 = lshr i64 %3, 20
// CHECK: %5 = and i64 %4, 1023
// CHECK: %6 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK: %7 = lshr i64 %6, 30
// CHECK: %addr.diff = sub i64 %7, lshr (i64 shl (i64 sub (i64 ptrtoint ([1 x i32]* @a to i64), i64 ptrtoint (i8* @__upc_shared_start to i64)), i64 30), i64 30)


int main() {
  return 0;
}
