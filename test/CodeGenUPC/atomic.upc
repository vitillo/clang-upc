// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - -verify

void inc(shared _Atomic(int) * ptr) { ++*ptr; } // expected-error{{cannot compile this atomic expression yet}}
