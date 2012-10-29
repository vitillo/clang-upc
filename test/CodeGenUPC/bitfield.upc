// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - | FileCheck %s

struct S {
  unsigned i1 : 10;
  unsigned i2 : 20;
  unsigned long i3 : 34;
};

unsigned read_bitfield(shared struct S* ptr) { return ptr->i2; }
// CHECK: read_bitfield
// CHECK:      %1 = load i64* %coerce.dive2
// CHECK-NEXT: %call = call i32 @__getsi2(i64 %1)
// CHECK-NEXT: %2 = lshr i32 %call, 10
// CHECK-NEXT: %bf.clear = and i32 %2, 1048575

void write_bitfield(shared struct S* ptr, unsigned val) { ptr->i2 = val; }
// CHECK: write_bitfield
// CHECK:      %4 = load i64* %coerce.dive2
// CHECK-NEXT: %call = call i32 @__getsi2(i64 %4)
// CHECK-NEXT: %5 = and i32 %call, -1073740801
// CHECK-NEXT: %6 = or i32 %5, %3
// CHECK:      %7 = load i64* %coerce.dive4
// CHECK-NEXT: call void @__putsi2(i64 %7, i32 %6)
