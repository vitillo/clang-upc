// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -fupc-debug -o - | FileCheck %s

const char * file() { return __FILE__; }
// CHECK: file
// CHECK: ret i8* [[__FILE__:getelementptr inbounds \(\[[0-9]+ x i8\]\* @.str, i32 0, i32 0\)]]

int * test_getaddr(shared int * ptr) { return (int*)ptr; }
// CHECK: test_getaddr
// CHECK: %1 = call i8* @__getaddrg(%__upc_shared_pointer_type %0, i8* [[__FILE__]], i32 7)

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
