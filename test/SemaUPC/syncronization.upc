// RUN: %clang_cc1 %s -fsyntax-only -verify

int main() {
  upc_notify;
  upc_wait;
  upc_barrier;
  upc_fence;
  upc_notify 1;
  upc_wait 1;
  upc_barrier 1;
  upc_notify (short)2;
  upc_wait (short)2;
  upc_barrier (short)2;
  upc_notify 3.14; // expected-error{{argument of 'upc_notify' has non-integer type 'double'}}
  upc_wait 3.14; // expected-error{{argument of 'upc_wait' has non-integer type 'double'}}
  upc_barrier 3.14; // expected-error{{argument of 'upc_barrier' has non-integer type 'double'}}
  upc_notify (void*)0; // expected-error{{argument of 'upc_notify' has non-integer type 'void *'}}
  upc_wait (void*)0; // expected-error{{argument of 'upc_wait' has non-integer type 'void *'}}
  upc_barrier (void*)0; // expected-error{{argument of 'upc_barrier' has non-integer type 'void *'}}
}
