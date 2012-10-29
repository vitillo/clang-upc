// RUN: %clang_cc1 %s -fsyntax-only -pedantic-errors -verify
// RUN: %clang_cc1 %s -fupc-threads 3 -fsyntax-only -pedantic-errors -verify

#define CAT_I(x, y) x ## y
#define CAT(x, y) CAT_I(x, y)
#define TEST(expr) char CAT(test, __LINE__)[(expr)? 1 : -1]

TEST(upc_elemsizeof(shared char) == 1);
TEST(upc_elemsizeof(shared int) == sizeof(int));
TEST(upc_elemsizeof(shared int[10]) == sizeof(int));
TEST(upc_elemsizeof(shared int[THREADS][10]) == sizeof(int));

struct incomplete; // expected-note{{}} // expected-note{{}}

int test() {
    int i1 = upc_elemsizeof(shared void); // expected-error{{invalid application of 'upc_elemsizeof' to a void type}}
    int i2 = upc_elemsizeof(shared struct incomplete); // expected-error{{invalid application of 'upc_elemsizeof' to an incomplete type}}
    int i3 = upc_elemsizeof(int (void)); // expected-error{{invalid application of 'upc_elemsizeof' to a shared-unqualified type}}
    int i4 = upc_elemsizeof(int); // expected-error{{invalid application of 'upc_elemsizeof' to a shared-unqualified type}}

    int i5 = upc_elemsizeof(*(shared void *)0); // expected-error{{invalid application of 'upc_elemsizeof' to a void type}}
    int i6 = upc_elemsizeof(*(shared struct incomplete *)0); // expected-error{{invalid application of 'upc_elemsizeof' to an incomplete type}}
    int i7 = upc_elemsizeof(*(int (*)(void))0); // expected-error{{invalid application of 'upc_elemsizeof' to a shared-unqualified type}}
    int i8 = upc_elemsizeof(*(int *)0); // expected-error{{invalid application of 'upc_elemsizeof' to a shared-unqualified type}}
}
