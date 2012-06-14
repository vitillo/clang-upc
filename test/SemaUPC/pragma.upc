// RUN: %clang_cc1 %s -fsyntax-only -verify

#pragma upc // expected-warning{{expected identifier in '#pragma upc' - ignored}}
#pragma upc bad // expected-warning{{expected 'strict' or 'relaxed' after '#pragma upc' - ignored}}
#pragma upc strict extra // expected-warning{{extra tokens at end of '#pragma upc' - ignored}}
#pragma upc relaxed extra // expected-warning{{extra tokens at end of '#pragma upc' - ignored}}

#pragma upc relaxed
#pragma upc strict

void f() {
#pragma upc relaxed
}

void g() {
    int i = 0;
    #pragma upc strict // expected-warning{{#pragma upc must precede all explicit declarations and statements in a compound statement}}
}
