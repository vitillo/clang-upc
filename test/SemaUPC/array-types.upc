// RUN: %clang_cc1 %s -verify

shared int test1[1][3*THREADS];
shared int test2[1][THREADS*3];

typedef shared int (*ptr_type)[(3)*THREADS];

ptr_type ptr1 = test1;
ptr_type ptr2 = test2;

shared int (*ptr3)[4*THREADS] = test1; // expected-warning{{incompatible pointer types}}

shared [] int array[10];
shared [] int array1[THREADS]; // expected-error{{THREADS may not be used in a shared array with indefinite block size}}

shared int err1[(int)THREADS]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err2[2*(int)THREADS]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err3[(int)THREADS*2]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err4[(int)(THREADS*2)]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err5[THREADS + 2]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}
shared int err6[10]; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}

extern shared int array2[];

shared int array3[] = { 1, 2, 3 }; // expected-error{{THREADS must appear exactly once in one dimension of a shared array}}

extern shared [*] int array4[][THREADS]; // expected-error{{cannot resolve block size of '*' on an incomplete array type}}

typedef int array_type2[THREADS];
shared [*] array_type2 array6[10];

typedef shared [*] int array_type4[7*THREADS]; // expected-error{{a layout qualifier of '*' is illegal in a typedef declaration}}

void f1(shared int[]);
void f2(shared int[10]);
void f3(shared int[THREADS]);
void f4(shared int[static 10]);
