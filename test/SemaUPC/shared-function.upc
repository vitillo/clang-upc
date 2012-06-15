// RUN: %clang_cc1 %s -fsyntax-only -verify

shared int f1(void); // expected-error{{function cannot return shared qualified type}}

void f2(shared int arg); // expected-error{{shared qualifier on function parameter}}

typedef int function_type(void);
typedef shared function_type * function_ptr_type; // expected-error{{shared qualifier on function type}}

void test() {
   (void)(shared int (*)(void))0; // expected-error{{function cannot return shared qualified type}}
   (void)(void (*)(shared int))0; // expected-error{{shared qualifier on function parameter}}
}
