// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - | FileCheck %s

typedef struct S_ { char data[20]; } S;

#pragma upc relaxed

void testc(shared char * ptr, char val) { *ptr = val; }
// CHECK: testc
// CHECK call void @__putqi2(i64 %1, i8 zeroext %0)

void testsc(shared signed char * ptr, signed char val) { *ptr = val; }
// CHECK: testsc
// CHECK call void @__putqi2(i64 %1, i8 zeroext %0)

void testuc(shared unsigned char * ptr, unsigned char val) { *ptr = val; }
// CHECK: testuc
// CHECK call void @__putqi2(i64 %1, i8 zeroext %0)

void tests(shared short * ptr, short val) { *ptr = val; }
// CHECK: tests
// CHECK call void @__puthi2(i64 %1, i16 zeroext %0)

void testus(shared unsigned short * ptr, unsigned short val) { *ptr = val; }
// CHECK: testus
// CHECK call void @__puthi2(i64 %1, i16 zeroext %0)

void testi(shared int * ptr, int val) { *ptr = val; }
// CHECK: testi
// CHECK call void @__putsi2(i64 %1, i32 %0)

void testui(shared unsigned int * ptr, unsigned int val) { *ptr = val; }
// CHECK: testui
// CHECK call void @__puthi2(i64 %1, i32 %0)

void testl(shared long * ptr, long val) { *ptr = val; }
// CHECK: testl
// CHECK call void @__putdi2(i64 %1, i64 %0)

void testul(shared unsigned long * ptr, unsigned long val) { *ptr = val; }
// CHECK: testul
// CHECK call void @__putdi2(i64 %1, i64 zeroext %0)

void testll(shared long long * ptr, long val) { *ptr = val; }
// CHECK: testll
// CHECK call void @__putdi2(i64 %1, i64 %0)

void testull(shared unsigned long long * ptr, unsigned long val) { *ptr = val; }
// CHECK: testull
// CHECK call void @__putdi2(i64 %1, i64 zeroext %0)

void testp(int * shared * ptr, int * val) { *ptr = val; }
// CHECK: testp
// CHECK: call void @__putdi2(i64 %1, i64 %2)

void testS(shared S * ptr, S * in) { *ptr = *in; }
// CHECK: testS
// CHECK: call void @__putblk3(i64 %0, i8* %2, i64 20)

#pragma upc strict

void testcs(shared char * ptr, char val) { *ptr = val; }
// CHECK: testcs
// CHECK call void @__putsqi2(i64 %1, i8 zeroext %0)

void testscs(shared signed char * ptr, signed char val) { *ptr = val; }
// CHECK: testscs
// CHECK call void @__putsqi2(i64 %1, i8 zeroext %0)

void testucs(shared unsigned char * ptr, unsigned char val) { *ptr = val; }
// CHECK: testucs
// CHECK call void @__putsqi2(i64 %1, i8 zeroext %0)

void testss(shared short * ptr, short val) { *ptr = val; }
// CHECK: testss
// CHECK call void @__putshi2(i64 %1, i16 zeroext %0)

void testuss(shared unsigned short * ptr, unsigned short val) { *ptr = val; }
// CHECK: testuss
// CHECK call void @__putshi2(i64 %1, i16 zeroext %0)

void testis(shared int * ptr, int val) { *ptr = val; }
// CHECK: testis
// CHECK call void @__putssi2(i64 %1, i32 %0)

void testuis(shared unsigned int * ptr, unsigned int val) { *ptr = val; }
// CHECK: testuis
// CHECK call void @__putshi2(i64 %1, i32 %0)

void testls(shared long * ptr, long val) { *ptr = val; }
// CHECK: testls
// CHECK call void @__putsdi2(i64 %1, i64 %0)

void testuls(shared unsigned long * ptr, unsigned long val) { *ptr = val; }
// CHECK: testuls
// CHECK call void @__putsdi2(i64 %1, i64 zeroext %0)

void testlls(shared long long * ptr, long val) { *ptr = val; }
// CHECK: testlls
// CHECK call void @__putsdi2(i64 %1, i64 %0)

void testulls(shared unsigned long long * ptr, unsigned long val) { *ptr = val; }
// CHECK: testulls
// CHECK call void @__putsdi2(i64 %1, i64 zeroext %0)

void testps(int * shared * ptr, int * val) { *ptr = val; }
// CHECK: testps
// CHECK: call void @__putsdi2(i64 %1, i64 %2)

void testSs(shared S * ptr, S * in) { *ptr = *in; }
// CHECK: testSs
// CHECK: call void @__putsblk3(i64 %0, i8* %2, i64 20)
