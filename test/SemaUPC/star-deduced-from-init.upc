// RUN: %ast_test -fupc-threads 2 %s

shared [*] int array[] = { 1, 2, 3, 4 }; // expected-decl-type{{shared [2] int [4]}}
