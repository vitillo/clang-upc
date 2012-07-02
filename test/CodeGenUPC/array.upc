// RUN: %clang_cc1 %s -emit-llvm -triple x86_64-pc-linux -fupc-threads 4 -o - | FileCheck %s

// simple
shared 
int a[4]; // = {1,2,3,4};

// messy
shared 
int b[5][3]; //  = {{1,2,3},{4,5,6},{7,8,9},{10,11,12},{13,14,15}};

void f(int i) {}

int main() {
  for(int i=0; i<4; ++i)
    f(a[i]);
  return 0;
}
