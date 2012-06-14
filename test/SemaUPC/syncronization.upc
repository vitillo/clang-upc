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
  upc_notify (void*)0; // expected-warning{{incompatible pointer to integer conversion}}
  upc_wait (void*)0; // expected-warning{{incompatible pointer to integer conversion}}
  upc_barrier (void*)0; // expected-warning{{incompatible pointer to integer conversion}}
}
