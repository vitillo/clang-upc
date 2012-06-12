// RUN: %clang_cc1 %s -fsyntax-only -verify
// RUN: %clang_cc1 %s -fupc-threads 3 -fsyntax-only -verify

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

#ifdef __UPC_DYNAMIC_THREADS__
TEST(upc_localsizeof(shared char[10]) == 10);
TEST(upc_localsizeof(shared [3] char [10]) == 12);
#else
TEST(upc_localsizeof(shared char[10]) == 4);
TEST(upc_localsizeof(shared [3] char [10]) == 6);
#endif
