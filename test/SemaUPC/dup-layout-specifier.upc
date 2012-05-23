// RUN: %clang_cc1 -fsyntax-only -verify %s

shared [3] shared [3] int i1; // expected-error{{cannot combine with previous 'shared' declaration specifier}}
typedef shared[3] int int_type;
shared [3] int_type i2; // expected-error{{cannot combine with previous 'shared' declaration specifier}}
shared int_type i3;
shared shared int i4;
shared [1] shared [1] int i6; // expected-error{{cannot combine with previous 'shared' declaration specifier}}
typedef shared [1] int int_type2;
shared [1] int_type2 i7; // expected-error{{cannot combine with previous 'shared' declaration specifier}}
int * shared [3] shared [3] pi1; // expected-error{{cannot combine with previous 'shared' declaration specifier}}
int * shared shared[3] pi2;
int * shared [3] shared pi3;
int * shared [1] shared [1] pi4; // expected-error{{cannot combine with previous 'shared' declaration specifier}}
