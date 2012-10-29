// RUN: %clang_cc1 -fsyntax-only %s -verify

shared int a[THREADS];

void test(int i) {
    switch(i) {
    case sizeof(a): break; // expected-error{{expression is not an integer constant expression}}
    }
}
