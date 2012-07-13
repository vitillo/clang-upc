// RUN: %clang_cc1 %s -fsyntax-only -verify

shared int array[10 * THREADS];

shared int * ptr1 = array;
shared int * ptr2 = array + 1;

shared int * getptr(void);
shared int * ptr3 = getptr();
