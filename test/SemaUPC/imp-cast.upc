// RUN: %clang_cc1 %s -DERRORS -fsyntax-only -verify
// RUN: %clang_cc1 %s -w -fsyntax-only -ast-dump | FileCheck %s

struct incomplete1;
struct incomplete2;
struct complete1 { char dummy[2]; };
struct complete2 { char dummy[2]; };

shared struct incomplete1 * ptr1;
shared struct complete1 * ptr2;
struct incomplete1 * ptr3;
int * ptr4;
shared [3] int * ptr5;
shared void * ptr6;
shared [2] struct incomplete1 * ptr7;

void f1(shared struct incomplete1 * arg); // expected-note{{}} // expected-note{{}} // expected-note{{}} // expected-note{{}}
void f2(shared struct incomplete2 * arg); // expected-note{{}} // expected-note{{}} // expected-note{{}}
void f3(shared struct complete1 * arg); // expected-note{{}} // expected-note{{}} // expected-note{{}} // expected-note{{}}
void f4(shared int * arg); // expected-note{{}} // expected-note{{}} // expected-note{{}} // expected-note{{}} // expected-note{{}}
void f5(shared [1] int * arg); // expected-note{{}}
void f6(shared [2] int * arg); // expected-note{{}} // expected-note{{}} // expected-note{{}}
void f7(struct incomplete1 * arg); // expected-note{{}} // expected-note{{}}
void f8(int * arg); // expected-note{{}} // expected-note{{}}
void f9(shared [2] struct incomplete1 * arg); // expected-note{{}} // expected-note{{}}
void f10(shared [2] struct complete1 * arg);  // expected-note{{}} // expected-note{{}} // expected-note{{}}
void f11(shared struct complete2 * arg); // expected-note{{}} // expected-note{{}}
void f12(shared [2] struct complete2 * arg);  // expected-note{{}} // expected-note{{}}
void f13(struct complete1 * arg); // expected-note{{}}
void f14(shared void * arg);
void f15(shared [] int * arg);
void f16(shared [3] struct incomplete1 *); // expected-note{{}}
void f17(shared [3] struct complete1 *); // expected-note{{}}

int main() {
    f1(ptr1);
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    f2(ptr1); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared struct incomplete2 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    f3(ptr1); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared struct complete1 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    f4(ptr1); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared int *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    f5(ptr1); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [1] int *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    f6(ptr1); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] int *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
#ifdef ERRORS
    f7(ptr1); // expected-error{{cannot convert pointer-to-shared to local pointer}}
    f8(ptr1); // expected-error{{cannot convert pointer-to-shared to local pointer}}
#endif

    f1(ptr2); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared struct incomplete1 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    f9(ptr2); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] struct incomplete1 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    f3(ptr2);
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    f10(ptr2); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] struct complete1 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    f11(ptr2); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared struct complete2 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    f12(ptr2); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] struct complete2 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    f4(ptr2); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared int *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    f6(ptr2); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] int *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'

#ifdef ERRORS
    f13(ptr2); // expected-error{{cannot convert pointer-to-shared to local pointer}}
    f7(ptr2); // expected-error{{cannot convert pointer-to-shared to local pointer}}
    f8(ptr2); // expected-error{{cannot convert pointer-to-shared to local pointer}}

    f1(ptr3); // expected-error{{cannot convert local pointer to pointer-to-shared}}
    f2(ptr3); // expected-error{{cannot convert local pointer to pointer-to-shared}}
    f3(ptr3); // expected-error{{cannot convert local pointer to pointer-to-shared}}
    f4(ptr3); // expected-error{{cannot convert local pointer to pointer-to-shared}}

    f1(ptr4); // expected-error{{cannot convert local pointer to pointer-to-shared}}
    f2(ptr4); // expected-error{{cannot convert local pointer to pointer-to-shared}}
    f3(ptr4); // expected-error{{cannot convert local pointer to pointer-to-shared}}
    f4(ptr4); // expected-error{{cannot convert local pointer to pointer-to-shared}}
#endif

    f1(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared struct incomplete1 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f9(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] struct incomplete1 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f3(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f10(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] struct complete1 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f11(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared struct complete2 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f12(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] struct complete2 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f4(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared int *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f6(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] int *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f14(ptr5);
    // CHECK: ImplicitCastExpr {{.*}} 'shared void *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f16(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [3] struct incomplete1 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'
    f17(ptr5); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [3] struct complete1 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr5'

    f4(ptr6);
    // CHECK: ImplicitCastExpr {{.*}} 'shared int *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr6'
    f15(ptr6);
    // CHECK: ImplicitCastExpr {{.*}} 'shared [0] int *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr6'
    f6(ptr6);
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] int *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr6'

    f10(ptr7); // expected-warning{{incompatible pointer types}}
    // CHECK: ImplicitCastExpr {{.*}} 'shared [2] struct complete1 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr7'

    f4((void*)0);
    // CHECK: ImplicitCastExpr {{.*}} 'shared int *' <NullToPointer>
}
