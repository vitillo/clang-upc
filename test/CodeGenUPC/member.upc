// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - | FileCheck %s

struct S {
  unsigned i1;
  unsigned i2;
  unsigned long i3;
};

unsigned read_member(shared struct S* ptr) { return ptr->i2; }
// CHECK: %1 = extractvalue %__upc_shared_pointer_type %0, 0
// CHECK-NEXT: %2 = lshr i64 %1, 30
// CHECK-NEXT: %3 = add i64 %2, 4
// CHECK: %call = call i32 @__getsi2(i64 %11)

void write_member(shared struct S* ptr, unsigned val) { ptr->i2 = val; }
// CHECK: %2 = extractvalue %__upc_shared_pointer_type %1, 0
// CHECK-NEXT: %3 = lshr i64 %2, 30
// CHECK-NEXT: %4 = add i64 %3, 4
// CHECK: call void @__putsi2(i64 %12, i32 %0)
