// RUN: %clang_cc1 -fsyntax-only %s -verify

shared [*] int *ptr; // expected-error{{A layout qualifier of '*' is illegal in a pointer type}}
