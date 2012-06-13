// RUN: %clang_cc1 %s -fsyntax-only -verify

shared int array[10 * THREADS];

shared int * ptr1 = array;
shared int * ptr2 = (shared int *)(shared char *)(array + 1); // pointer with zero phase

shared int * getptr(void);
shared int * ptr3 = getptr(); // expected-error{{initializer element is not a compile-time constant}}
