// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -o - -verify

void compound_assign(shared _Atomic(int) * ptr) { *ptr += 2; } // expected-error{{cannot compile this atomic expression yet}}
