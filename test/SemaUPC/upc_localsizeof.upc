// RUN: %clang_cc1 %s -fsyntax-only -pedantic-errors -verify
// RUN: %clang_cc1 %s -fupc-threads 3 -fsyntax-only -pedantic-errors -verify

#define CAT_I(x, y) x ## y
#define CAT(x, y) CAT_I(x, y)
#define TEST(expr) char CAT(test, __LINE__)[(expr)? 1 : -1]

TEST(upc_localsizeof(shared char) == 1);
TEST(upc_localsizeof(shared char[THREADS]) == 1);
TEST(upc_localsizeof(shared char[3*THREADS]) == 3);
TEST(upc_localsizeof(shared [4] char[7*THREADS]) == 8);
TEST(upc_localsizeof(shared [] char[10]) == 10);
TEST(upc_localsizeof(shared [3] char [5][THREADS]) == 6);
TEST(upc_localsizeof(shared [3] char [THREADS][5]) == 6);

typedef shared char array_type[10][THREADS];
TEST(upc_localsizeof(array_type) == 10);

#ifdef __UPC_DYNAMIC_THREADS__
TEST(upc_localsizeof(shared char[10]) == 10);
TEST(upc_localsizeof(shared [3] char [10]) == 12);
#else
TEST(upc_localsizeof(shared char[10]) == 4);
TEST(upc_localsizeof(shared [3] char [10]) == 6);
#endif

struct incomplete; // expected-note{{}} // expected-note{{}}

int test() {
    int i1 = upc_localsizeof(shared void); // expected-error{{invalid application of 'upc_localsizeof' to a void type}}
    int i2 = upc_localsizeof(shared struct incomplete); // expected-error{{invalid application of 'upc_localsizeof' to an incomplete type}}
    int i3 = upc_localsizeof(int (void)); // expected-error{{invalid application of 'upc_localsizeof' to a shared-unqualified type}}
    int i4 = upc_localsizeof(int); // expected-error{{invalid application of 'upc_localsizeof' to a shared-unqualified type}}

    int i5 = upc_localsizeof(*(shared void *)0); // expected-error{{invalid application of 'upc_localsizeof' to a void type}}
    int i6 = upc_localsizeof(*(shared struct incomplete *)0); // expected-error{{invalid application of 'upc_localsizeof' to an incomplete type}}
    int i7 = upc_localsizeof(*(int (*)(void))0); // expected-error{{invalid application of 'upc_localsizeof' to a shared-unqualified type}}
    int i8 = upc_localsizeof(*(int *)0); // expected-error{{invalid application of 'upc_localsizeof' to a shared-unqualified type}}
}
