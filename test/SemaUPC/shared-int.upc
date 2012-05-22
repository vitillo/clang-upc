// RUN: %ast_test %s

shared int i; // expected-decl-type{{shared int}}
char j; // expected-decl-type{{int}}
