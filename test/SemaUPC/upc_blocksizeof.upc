// RUN: %clang_cc1 %s -fsyntax-only -verify
// RUN: %clang_cc1 %s -fupc-threads 3 -fsyntax-only -verify

#define CAT_I(x, y) x ## y
#define CAT(x, y) CAT_I(x, y)
#define TEST(expr) char CAT(test, __LINE__)[(expr)? 1 : -1]

TEST(upc_blocksizeof(shared int) == 1);
TEST(upc_blocksizeof(shared int[THREADS]) == 1);
TEST(upc_blocksizeof(shared int[3*THREADS]) == 1);
TEST(upc_blocksizeof(shared [4] int[7*THREADS]) == 4);
TEST(upc_blocksizeof(shared [] int[10]) == 0);
TEST(upc_blocksizeof(shared [*] int[10*THREADS]) == 10);
