// RUN: %clang_cc1 %s -fsyntax-only -verify

struct unint_t {} unint;

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
  upc_notify 3.14; // expected-warning{{implicit conversion turns literal floating-point number into integer: 'double' to 'int'}}
  upc_wait 3.14; // expected-warning{{implicit conversion turns literal floating-point number into integer: 'double' to 'int'}}
  upc_barrier 3.14; // expected-warning{{implicit conversion turns literal floating-point number into integer: 'double' to 'int'}}
  upc_notify unint; // expected-error{{casting 'struct unint_t' to incompatible type 'int'}}
  upc_wait unint; // expected-error{{casting 'struct unint_t' to incompatible type 'int'}}
  upc_barrier unint; // expected-error{{casting 'struct unint_t' to incompatible type 'int'}}
}
