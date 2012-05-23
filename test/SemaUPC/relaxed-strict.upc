// RUN: %clang_cc1 -fsyntax-only -verify %s

relaxed strict shared int i1; // expected-error{{cannot combine with previous 'relaxed' declaration specifier}}
typedef relaxed shared int relaxed_type;
typedef strict shared int strict_type;
strict relaxed_type i2; // expected-error{{cannot combine with previous 'relaxed' declaration specifier}}
relaxed strict_type i3; // expected-error{{cannot combine with previous 'strict' declaration specifier}}
strict strict_type i4;
relaxed relaxed_type i5;
