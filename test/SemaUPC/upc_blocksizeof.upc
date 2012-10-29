// RUN: %clang_cc1 %s -fsyntax-only -pedantic-errors -verify
// RUN: %clang_cc1 %s -fupc-threads 3 -fsyntax-only -pedantic-errors -verify

#define CAT_I(x, y) x ## y
#define CAT(x, y) CAT_I(x, y)
#define TEST(expr) char CAT(test, __LINE__)[(expr)? 1 : -1]

TEST(upc_blocksizeof(shared int) == 1);
TEST(upc_blocksizeof(shared int[THREADS]) == 1);
TEST(upc_blocksizeof(shared int[3*THREADS]) == 1);
TEST(upc_blocksizeof(shared [4] int[7*THREADS]) == 4);
TEST(upc_blocksizeof(shared [] int[10]) == 0);
TEST(upc_blocksizeof(shared [*] int[10*THREADS]) == 10);

struct incomplete; // expected-note{{}} // expected-note{{}}

int test() {
    int i1 = upc_blocksizeof(shared void); // expected-error{{invalid application of 'upc_blocksizeof' to a void type}}
    int i2 = upc_blocksizeof(shared struct incomplete); // expected-error{{invalid application of 'upc_blocksizeof' to an incomplete type}}
    int i3 = upc_blocksizeof(int (void)); // expected-error{{invalid application of 'upc_blocksizeof' to a shared-unqualified type}}
    int i4 = upc_blocksizeof(int); // expected-error{{invalid application of 'upc_blocksizeof' to a shared-unqualified type}}

    int i5 = upc_blocksizeof(*(shared void *)0); // expected-error{{invalid application of 'upc_blocksizeof' to a void type}}
    int i6 = upc_blocksizeof(*(shared struct incomplete *)0); // expected-error{{invalid application of 'upc_blocksizeof' to an incomplete type}}
    int i7 = upc_blocksizeof(*(int (*)(void))0); // expected-error{{invalid application of 'upc_blocksizeof' to a shared-unqualified type}}
    int i8 = upc_blocksizeof(*(int *)0); // expected-error{{invalid application of 'upc_blocksizeof' to a shared-unqualified type}}
}
