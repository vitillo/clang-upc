// RUN: %clang_cc1 %s -fsyntax-only -verify

shared int *p1, *p2;
int * p3;
shared [1] int *p4;
shared [] int *p5;
shared [2] int *p6;
shared void * p7;
shared struct incomplete *p8, *p9; // expected-note{{}}

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

  (void)(p8 -  p9); // expected-error{{arithmetic on a pointer to an incomplete type}}
  (void)(p8 == p9);
  (void)(p8 != p9);
  (void)(p8 <  p9); // expected-error{{relational comparison on a pointer-to-shared to an incomplete type}}
  (void)(p8 <= p9); // expected-error{{relational comparison on a pointer-to-shared to an incomplete type}}
  (void)(p8 >  p9); // expected-error{{relational comparison on a pointer-to-shared to an incomplete type}}
  (void)(p8 >= p9); // expected-error{{relational comparison on a pointer-to-shared to an incomplete type}}

  (void)(1? p1 : p3); // expected-error{{incompatible operand types}}
  p1 = 1? p1 : p4;
  shared void * vp = 1? p1 : p5; // expected-warning{{pointer type mismatch}}
  (void)(vp + 1); // expected-error{{arithmetic on a pointer to void}}
  (void)(1 + vp); // expected-error{{arithmetic on a pointer to void}}
  (void)(vp - 1); // expected-error{{arithmetic on a pointer to void}}
  (void)(vp - vp); // expected-error{{arithmetic on pointers to void}}
  (void)(vp == p6);
  (void)(p6 == vp);
}
