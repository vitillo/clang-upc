// RUN: %clang_cc1 %s -fsyntax-only -verify

shared int array1[THREADS];
shared [10] int array2[THREADS][10];

int main() {
    {
        int i;
        upc_forall(i = 0; i < THREADS; ++i; i) {}
    }
    upc_forall(int i = 0; i < THREADS; ++i;) {}
    upc_forall(int i = 0; i < THREADS; ++i; continue) {}
    upc_forall(int i = 0; i < THREADS; ++i; i) {}
    upc_forall(int i = 0; i < THREADS; ++i; &array1[i]) {}
    upc_forall(int i = 0; i < THREADS; ++i; array2[i]) {}
    upc_forall(int i = 0; i < THREADS; ++i; 1.0) {} // expected-error{{affinity type 'double' is not an integer or pointer-to-shared type}}
    upc_forall(int i = 0; i < THREADS; ++i; (void*)0) {} // expected-error{{affinity type 'void *' is not an integer or pointer-to-shared type}}

    typedef shared int * shared_pointer_type;
    upc_forall(int i = 0; i < THREADS; ++i; (shared_pointer_type)(array1 + i)) {}
}

void f(int val) {
    int i;
    goto label1; // expected-warning{{entering upc_forall with 'goto' has undefined behavior}}
    switch(val) {
        upc_forall(i = 0; i < THREADS; ++i; i)
        {
            case 0: // expected-warning{{entering upc_forall with 'switch' has undefined behavior}}
            default: // expected-warning{{entering upc_forall with 'switch' has undefined behavior}}
            label1:
            break; // expected-warning{{exiting upc_forall with 'break' has undefined behavior}}
            goto label1;
            goto label2; // expected-warning{{exiting upc_forall with 'goto' has undefined behavior}}
            do {
              return; // expected-warning{{exiting upc_forall with 'return' has undefined behavior}}
            } while(0);
        }
    }
    label2:;
}
