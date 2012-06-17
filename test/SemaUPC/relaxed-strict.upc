// RUN: %clang_cc1 -fsyntax-only -fupc-threads 2 -verify %s

relaxed strict shared int i1; // expected-error{{cannot combine with previous 'relaxed' declaration specifier}}
typedef relaxed shared int relaxed_type;
typedef strict shared int strict_type;
strict relaxed_type i2; // expected-error{{cannot combine with previous 'relaxed' declaration specifier}}
relaxed strict_type i3; // expected-error{{cannot combine with previous 'strict' declaration specifier}}
strict strict_type i4;
relaxed relaxed_type i5;

relaxed int i6; // expected-error{{'relaxed' illegal on shared-unqualified type 'int'}}
strict int i7; // expected-error{{'strict' illegal on shared-unqualified type 'int'}}
int * relaxed ip1; // expected-error{{'relaxed' illegal on shared-unqualified type 'int *'}}
int * strict ip2; // expected-error{{'strict' illegal on shared-unqualified type 'int *'}}
