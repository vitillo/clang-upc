// RUN: %clang_cc1 %s -fsyntax-only -DEXPECTED=8 -verify
// RUN: %clang_cc1 %s -fsyntax-only -fupc-pts=struct -DEXPECTED=16 -verify

#define CAT_I(x, y) x ## y
#define CAT(x, y) CAT_I(x, y)
#define TEST(expr) char CAT(test, __LINE__)[(expr)? 1 : -1]

TEST(sizeof(shared void *) == EXPECTED);
