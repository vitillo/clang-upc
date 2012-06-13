// RUN: %clang_cc1 %s -DERRORS -fsyntax-only -verify
// RUN: %clang_cc1 %s -fsyntax-only -ast-dump | FileCheck %s

struct incomplete1;
struct incomplete2;
struct complete1 { char dummy[2]; };
struct complete2 { char dummy[2]; };

shared struct incomplete1 * ptr1;
shared struct complete1 * ptr2;
struct incomplete1 * ptr3;
int * ptr4;

int main() { // CHECK: int main()
    (void)(shared struct incomplete1 *)ptr1;
    // CHECK: CStyleCastExpr {{.*}} 'shared struct incomplete1 *' <NoOp>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    (void)(shared struct incomplete2 *)ptr1;
    // CHECK: CStyleCastExpr {{.*}} 'shared struct incomplete2 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    (void)(shared struct complete1 *)ptr1;
    // CHECK: CStyleCastExpr {{.*}} 'shared struct complete1 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    (void)(shared int *)ptr1;
    // CHECK: CStyleCastExpr {{.*}} 'shared int *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    (void)(shared [1] int *)ptr1;
    // CHECK: CStyleCastExpr {{.*}} 'shared [1] int *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    (void)(shared [2] int *)ptr1;
    // CHECK: CStyleCastExpr {{.*}} 'shared [2] int *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    (void)(struct incomplete1 *)ptr1;
    // CHECK: CStyleCastExpr {{.*}} 'struct incomplete1 *' <UPCSharedToLocal>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'
    (void)(int *)ptr1;
    // CHECK: CStyleCastExpr {{.*}} 'int *' <UPCSharedToLocal>
    // CHECK: DeclRefExpr {{.*}} 'ptr1'

    (void)(shared struct incomplete1 *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'shared struct incomplete1 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(shared [2] struct incomplete1 *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'shared [2] struct incomplete1 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(shared struct complete1 *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'shared struct complete1 *' <NoOp>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(shared [2] struct complete1 *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'shared [2] struct complete1 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(shared struct complete2 *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'shared struct complete2 *' <BitCast>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(shared [2] struct complete2 *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'shared [2] struct complete2 *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(shared int *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'shared int *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(shared [2] int *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'shared [2] int *' <UPCBitCastZeroPhase>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(struct complete1 *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'struct complete1 *' <UPCSharedToLocal>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(struct incomplete1 *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'struct incomplete1 *' <UPCSharedToLocal>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'
    (void)(int *)ptr2;
    // CHECK: CStyleCastExpr {{.*}} 'int *' <UPCSharedToLocal>
    // CHECK: DeclRefExpr {{.*}} 'ptr2'

#ifdef ERRORS
    (void)(shared struct incomplete1 *)ptr3; // expected-error{{cannot convert local pointer to pointer-to-shared}}
    (void)(shared struct incomplete2 *)ptr3; // expected-error{{cannot convert local pointer to pointer-to-shared}}
    (void)(shared struct complete1 *)ptr3; // expected-error{{cannot convert local pointer to pointer-to-shared}}
    (void)(shared int *)ptr3; // expected-error{{cannot convert local pointer to pointer-to-shared}}

    (void)(shared struct incomplete1 *)ptr4; // expected-error{{cannot convert local pointer to pointer-to-shared}}
    (void)(shared struct incomplete2 *)ptr4; // expected-error{{cannot convert local pointer to pointer-to-shared}}
    (void)(shared struct complete1 *)ptr4; // expected-error{{cannot convert local pointer to pointer-to-shared}}
    (void)(shared int *)ptr4; // expected-error{{cannot convert local pointer to pointer-to-shared}}
#endif
}
