// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - | FileCheck %s

// Make sure that a UPC array type behaves like a
// variables array when it isn't declared shared.

typedef int array_type[10][THREADS][7];

array_type * test_non_shared_add(array_type * ptr, int x) { return ptr + x; }
// CHECK: test_non_shared_add
// CHECK: %0 = load [7 x i32]** %ptr.addr, align 8
// CHECK-NEXT: %1 = load i32* %x.addr, align 4
// CHECK-NEXT: %idx.ext = sext i32 %1 to i64
// CHECK-NEXT: %2 = load i32* @THREADS
// CHECK-NEXT: %3 = zext i32 %2 to i64
// CHECK-NEXT: %4 = mul nuw i64 1, %3
// CHECK-NEXT: %5 = mul nuw i64 10, %4
// CHECK-NEXT: %vla.index = mul nsw i64 %idx.ext, %5
// CHECK-NEXT: %add.ptr = getelementptr inbounds [7 x i32]* %0, i64 %vla.index

array_type * test_non_shared_subscript(array_type * ptr, int x) { return &ptr[x]; }
// CHECK: test_non_shared_subscript
// CHECK: %0 = load i32* %x.addr, align 4
// CHECK-NEXT: %idxprom = sext i32 %0 to i64
// CHECK-NEXT: %1 = load [7 x i32]** %ptr.addr, align 8
// CHECK-NEXT: %2 = load i32* @THREADS
// CHECK-NEXT: %3 = zext i32 %2 to i64
// CHECK-NEXT: %4 = mul nuw i64 1, %3
// CHECK-NEXT: %5 = mul nuw i64 10, %4
// CHECK-NEXT: %6 = mul nsw i64 %idxprom, %5
// CHECK-NEXT: %arrayidx = getelementptr inbounds [7 x i32]* %1, i64 %6

int test_non_shared_minus(array_type * ptr1, array_type * ptr2) { return ptr1 - ptr2; }
// CHECK: %0 = load [7 x i32]** %ptr1.addr, align 8
// CHECK-NEXT: %1 = load [7 x i32]** %ptr2.addr, align 8
// CHECK-NEXT: %sub.ptr.lhs.cast = ptrtoint [7 x i32]* %0 to i64
// CHECK-NEXT: %sub.ptr.rhs.cast = ptrtoint [7 x i32]* %1 to i64
// CHECK-NEXT: %sub.ptr.sub = sub i64 %sub.ptr.lhs.cast, %sub.ptr.rhs.cast
// CHECK-NEXT: %2 = load i32* @THREADS
// CHECK-NEXT: %3 = zext i32 %2 to i64
// CHECK-NEXT: %4 = mul nuw i64 1, %3
// CHECK-NEXT: %5 = mul nuw i64 10, %4
// CHECK-NEXT: %6 = mul nuw i64 28, %5
// CHECK-NEXT: %sub.ptr.div = sdiv exact i64 %sub.ptr.sub, %6

void test_non_shared_increment(array_type * * ptr) { ++*ptr; }
// CHECK: test_non_shared_increment
// CHECK: %1 = load [7 x i32]** %0, align 8
// CHECK-NEXT: %2 = load i32* @THREADS
// CHECK-NEXT: %3 = zext i32 %2 to i64
// CHECK-NEXT: %4 = mul nuw i64 1, %3
// CHECK-NEXT: %5 = mul nuw i64 10, %4
// CHECK-NEXT: %vla.inc = getelementptr inbounds [7 x i32]* %1, i64 %5

void test_non_shared_decl() {
    array_type arr;
    test_non_shared_add(&arr, 2);
}
// CHECK: test_non_shared_decl
// CHECK: %1 = load i32* @THREADS
// CHECK-NEXT: %2 = zext i32 %1 to i64
// CHECK-NEXT: %3 = mul nuw i64 1, %2
// CHECK-NEXT: %4 = mul nuw i64 10, %3
// CHECK-NEXT: %vla = alloca [7 x i32], i64 %4, align 4
// CHECK-NEXT: %call = call [7 x i32]* @test_non_shared_add([7 x i32]* %vla, i32 2)

int test_sizeof() { return sizeof(array_type); }
// CHECK: test_sizeof
// CHECK: %0 = load i32* @THREADS
// CHECK-NEXT: %1 = zext i32 %0 to i64
// CHECK-NEXT: %2 = mul nuw i64 1, %1
// CHECK-NEXT: %3 = mul nuw i64 10, %2
// CHECK-NEXT: %4 = mul nuw i64 28, %3
// CHECK-NEXT: %conv = trunc i64 %4 to i32
