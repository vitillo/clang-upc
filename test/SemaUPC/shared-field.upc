// RUN: %clang_cc1 -fsyntax-only -verify %s

struct S {
  shared int f[THREADS]; // expected-error{{Fields may not be declared with UPC shared qualifier}}
};
