// RUN: %clang_cc1 -fsyntax-only -verify %s

int main() {
  shared int i[THREADS]; // expected-error{{Automatic variables may not be declared shared}}
}
