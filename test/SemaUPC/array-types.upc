// RUN: %clang_cc1 %s -verify

shared int test1[1][3*THREADS];
shared int test2[1][THREADS*3];

typedef shared int (*ptr_type)[(3)*THREADS];

ptr_type ptr1 = test1;
ptr_type ptr2 = test2;

shared int (*ptr3)[4*THREADS] = test1; // expected-warning{{incompatible pointer types}}

shared [] int array[10];
shared [] int array[THREADS]; // expected-error{{THREADS may not be used in a shared array with indefinite block size}}

shared int err1[(int)THREADS]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err2[2*(int)THREADS]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err3[(int)THREADS*2]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err4[(int)(THREADS*2)]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err5[THREADS + 2]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err6[10]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
