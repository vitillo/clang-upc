// RUN: %clang_cc1 %s -fsyntax-only -verify
// RUN: %clang_cc1 %s -w -fsyntax-only -ast-dump | FileCheck %s

#pragma upc // expected-warning{{expected identifier in '#pragma upc' - ignored}}
#pragma upc bad // expected-warning{{expected 'strict' or 'relaxed' after '#pragma upc' - ignored}}
#pragma upc strict extra // expected-warning{{extra tokens at end of '#pragma upc' - ignored}}
#pragma upc relaxed extra // expected-warning{{extra tokens at end of '#pragma upc' - ignored}}

#pragma upc relaxed
#pragma upc strict

shared int i;

void f() { // CHECK: void f()
#pragma upc relaxed
    int j1 = i;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i = 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i += 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i -= 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i *= 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i /= 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i %= 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i &= 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i |= 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i ^= 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i <<= 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    i >>= 1;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
}

void g() { // CHECK: void g()
    int j1 = i;
    // CHECK: ImplicitCastExpr {{.*}} 'shared strict int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
    #pragma upc relaxed // expected-warning{{#pragma upc must precede all explicit declarations and statements in a compound statement}}
    int j2 = i;
    // CHECK: ImplicitCastExpr {{.*}} 'shared relaxed int' lvalue <LValueBitCast>
    // CHECK-NEXT: DeclRefExpr {{.*}} 'i'
}
