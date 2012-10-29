// RUN: %clang_cc1 %s -fsyntax-only -verify

shared int f1(void); // expected-error{{function cannot return shared qualified type}}
void f2(shared int arg); // expected-error{{shared qualifier on function parameter}}
typedef shared int f3(void); // expected-error{{function cannot return shared qualified type}}
typedef void f4(shared int); // expected-error{{shared qualifier on function parameter}}

typedef int function_type(void);
typedef shared function_type * function_ptr_type; // expected-error{{shared qualifier on function type}}

void test() {
  (void)(shared int (*)(void))0; // expected-error{{function cannot return shared qualified type}}
  (void)(void (*)(shared int))0; // expected-error{{shared qualifier on function parameter}}
  shared int i[THREADS]; // expected-error{{shared qualifier on automatic variable}}
}

struct S {
  shared int f[THREADS]; // expected-error{{shared qualifier on field}} // expected-error{{fields must have a constant size}}
};

shared [*] int *ptr; // expected-error{{a layout qualifier of '*' is illegal in a pointer type}}

shared [1] void *vptr; // expected-error{{layout qualifier on generic pointer-to-shared}}
