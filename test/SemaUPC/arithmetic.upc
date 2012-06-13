// RUN: %clang_cc1 %s -fsyntax-only -verify

shared int *p1, *p2;
int * p3;
shared [1] int *p4;
shared [] int *p5;
shared [2] int *p6;

int main() {
  p2 = p1 + 1;
  p2 = 1 + p1;
  p2 = p1 - 1;
  int diff = p2 - p1;
  int cmp = p1 == p2;
  cmp = p1 != p2;
  cmp = p1 < p2;
  cmp = p1 <= p2;
  cmp = p1 > p2;
  cmp = p1 >= p2;
  cmp = p1 == 0;
  cmp = p1 != 0;

  (void)(p1 -  p3); // expected-error{{not pointers to compatible types}}
  (void)(p1 == p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 != p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 <  p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 <= p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 >  p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 >= p3); // expected-error{{comparison of distinct pointer types}}

  (void)(p1 -  p4);
  (void)(p1 == p4);
  (void)(p1 != p4);
  (void)(p1 <  p4);
  (void)(p1 <= p4);
  (void)(p1 >  p4);
  (void)(p1 >= p4);

  (void)(p1 -  p5); // expected-error{{not pointers to compatible types}}
  (void)(p1 == p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 != p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 <  p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 <= p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 >  p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 >= p5); // expected-error{{comparison of distinct pointer types}}

  (void)(p1 -  p6); // expected-error{{not pointers to compatible types}}
  (void)(p1 == p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 != p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 <  p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 <= p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 >  p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p1 >= p6); // expected-error{{comparison of distinct pointer types}}

  (void)(p3 -  p1); // expected-error{{not pointers to compatible types}}
  (void)(p3 == p1); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 != p1); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 <  p1); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 <= p1); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 >  p1); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 >= p1); // expected-error{{comparison of distinct pointer types}}

  (void)(p3 -  p4); // expected-error{{not pointers to compatible types}}
  (void)(p3 == p4); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 != p4); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 <  p4); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 <= p4); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 >  p4); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 >= p4); // expected-error{{comparison of distinct pointer types}}

  (void)(p3 -  p5); // expected-error{{not pointers to compatible types}}
  (void)(p3 == p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 != p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 <  p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 <= p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 >  p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 >= p5); // expected-error{{comparison of distinct pointer types}}

  (void)(p3 -  p6); // expected-error{{not pointers to compatible types}}
  (void)(p3 == p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 != p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 <  p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 <= p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 >  p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p3 >= p6); // expected-error{{comparison of distinct pointer types}}

  (void)(p4 -  p1);
  (void)(p4 == p1);
  (void)(p4 != p1);
  (void)(p4 <  p1);
  (void)(p4 <= p1);
  (void)(p4 >  p1);
  (void)(p4 >= p1);

  (void)(p4 -  p3); // expected-error{{not pointers to compatible types}}
  (void)(p4 == p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 != p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 <  p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 <= p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 >  p3); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 >= p3); // expected-error{{comparison of distinct pointer types}}

  (void)(p4 -  p5); // expected-error{{not pointers to compatible types}}
  (void)(p4 == p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 != p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 <  p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 <= p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 >  p5); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 >= p5); // expected-error{{comparison of distinct pointer types}}

  (void)(p4 -  p6); // expected-error{{not pointers to compatible types}}
  (void)(p4 == p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 != p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 <  p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 <= p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 >  p6); // expected-error{{comparison of distinct pointer types}}
  (void)(p4 >= p6); // expected-error{{comparison of distinct pointer types}}
}
