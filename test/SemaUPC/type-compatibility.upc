// RUN: %clang_cc1 %s -fsyntax-only -verify

shared int **p1;
shared [1] int **p2;
shared [] int **p3;
shared [2] int **p4;

int main() {
  (void)(p1 == p2);
  (void)(p1 == p3); // expected-warning{{comparison of distinct pointer types}}
  (void)(p1 == p4); // expected-warning{{comparison of distinct pointer types}}

  (void)(p2 == p1);
  (void)(p2 == p3); // expected-warning{{comparison of distinct pointer types}}
  (void)(p2 == p4); // expected-warning{{comparison of distinct pointer types}}

  (void)(p3 == p1); // expected-warning{{comparison of distinct pointer types}}
  (void)(p3 == p2); // expected-warning{{comparison of distinct pointer types}}
  (void)(p3 == p4); // expected-warning{{comparison of distinct pointer types}}

  (void)(p4 == p1); // expected-warning{{comparison of distinct pointer types}}
  (void)(p4 == p2); // expected-warning{{comparison of distinct pointer types}}
  (void)(p4 == p3); // expected-warning{{comparison of distinct pointer types}}
}
