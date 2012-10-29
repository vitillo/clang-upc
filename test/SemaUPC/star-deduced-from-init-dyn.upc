// RUN: %ast_test %s

shared [*] int array[][THREADS] = { {}, {} }; // expected-decl-type{{shared [2] int [2][THREADS]}}
