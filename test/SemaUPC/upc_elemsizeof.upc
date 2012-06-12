// RUN: %clang_cc1 %s -fsyntax-only -verify
// RUN: %clang_cc1 %s -fupc-threads 3 -fsyntax-only -verify

#define CAT_I(x, y) x ## y
#define CAT(x, y) CAT_I(x, y)
#define TEST(expr) char CAT(test, __LINE__)[(expr)? 1 : -1]

TEST(upc_elemsizeof(shared char) == 1);
TEST(upc_elemsizeof(shared int) == sizeof(int));
TEST(upc_elemsizeof(shared int[10]) == sizeof(int));
TEST(upc_elemsizeof(shared int[THREADS][10]) == sizeof(int));
