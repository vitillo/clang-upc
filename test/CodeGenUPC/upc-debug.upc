// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -fupc-debug -o - | FileCheck %s

const char * file() { return __FILE__; }
// CHECK: file
// CHECK: ret i8* [[__FILE__:getelementptr inbounds \(\[[0-9]+ x i8\]\* @.str, i32 0, i32 0\)]]

int * test_getaddr(shared int * ptr) { return (int*)ptr; }
// CHECK: test_getaddr
// CHECK: %call = call i8* @__getaddrg(i64 %1, i8* [[__FILE__]], i32 7)

int test_getsi(shared int *ptr) { return *ptr; }
// CHECK: test_getsi
// CHECK: %call = call i32 @__getgsi3(i64 %1, i8* [[__FILE__]], i32 11)

void test_putsi(shared int *ptr, int val) { *ptr = val; }
// CHECK: test_putsi
// CHECK: call void @__putgsi4(i64 %2, i32 %0, i8* [[__FILE__]], i32 15)

struct S { char array[10]; };

void test_agg_get(struct S *dst, shared struct S *src) { *dst = *src; }
// CHECK: test_agg_get
// CHECK: call void @__getgblk5(i8* %2, i64 %3, i64 10, i8* [[__FILE__]], i32 21)

void test_agg_put(shared struct S *dst, struct S *src) { *dst = *src; }
// CHECK: test_agg_put
// CHECK: call void @__putgblk5(i64 %2, i8* %3, i64 10, i8* [[__FILE__]], i32 25)

void test_agg_copy(shared struct S *dst, shared struct S *src) { *dst = *src; }
// CHECK: test_agg_copy
// CHECK: call void @__copygblk5(i64 %2, i64 %3, i64 10, i8* [[__FILE__]], i32 29)

void test_notify() { upc_notify; }
// CHECK: test_notify
// CHECK: call void @__upc_notifyg(i32 -2147483648, i8* [[__FILE__]], i32 33)

void test_wait() { upc_wait; }
// CHECK: test_wait
// CHECK: call void @__upc_waitg(i32 -2147483648, i8* [[__FILE__]], i32 37)

void test_barrier() { upc_barrier; }
// CHECK: test_barrier
// CHECK: call void @__upc_barrierg(i32 -2147483648, i8* [[__FILE__]], i32 41)

typedef struct BitField_ {
  unsigned i1 : 10;
  unsigned i2 : 12;
  unsigned i3 : 10 ;
} BitField;

unsigned test_bitfield_load(shared BitField * ptr) { return ptr->i2; }
// CHECK: test_bitfield_load
// CHECK: %call = call i32 @__getgsi3(i64 %1, i8* [[__FILE__]], i32 51)

void test_bitfield_store(shared BitField * ptr, unsigned val) { ptr->i2 = val; }
// CHECK: test_bitfield_store
// CHECK: %call = call i32 @__getgsi3(i64 %4, i8* [[__FILE__]], i32 55)
// CHECK: call void @__putgsi4(i64 %7, i32 %6, i8* [[__FILE__]], i32 55)
