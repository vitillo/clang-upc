// RUN %clang_cc1 -fsyntax-only -verify %s

shared [UPC_MAX_BLOCK_SIZE] int okay;
shared [(unsigned long long)UPC_MAX_BLOCK_SIZE + 1] int err; // expected-error-re{{Block size [[:digit:]]+ exceeds UPC_MAX_BLOCK_SIZE}}
