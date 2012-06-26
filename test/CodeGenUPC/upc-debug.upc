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
