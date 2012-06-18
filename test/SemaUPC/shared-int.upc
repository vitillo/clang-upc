// RUN: %ast_test -fupc-threads 1 %s
// RUN: %ast_test %s

shared int i; // expected-decl-type{{shared int}}
shared int * shared pi; // expected-decl-type{{shared int *shared}}
shared int * frsi(void); // expected-decl-type{{shared int *(void)}}
void fpsi(shared int*); // expected-decl-type{{void (shared int *)}}
shared int * (* shared pfrsipsi)(shared int *); // expected-decl-type{{shared int *(*shared)(shared int *)}}

shared [3] int s3i; // expected-decl-type{{shared [3] int}}
shared [] int sei; // expected-decl-type{{shared [0] int}}
shared [*] int ssi; // expected-decl-type{{shared [1] int}}

typedef shared int int_type;
int_type * ti; // expected<<ignored>>-decl-type{{shared int *}}

shared [4] int *(*shared [4] psf4)(shared [4] int *); // expected-decl-type{{shared [4] int *(*shared [4])(shared [4] int *)}}

struct struct_type {
  int value;
};

shared struct struct_type s;
shared [] int * struct_element_ptr = &s.value;
