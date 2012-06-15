// RUN: %clang_cc1 %s -fsyntax-only -fupc-packed-bits=15,15,34
// RUN: %clang_cc1 %s -fsyntax-only -fupc-packed-bits=one,two,three 2>&1 | FileCheck -check-prefix=CHECK1
// CHECK1: invalid value 'one,two,three'
// RUN: %clang_cc1 %s -fsyntax-only -fupc-packed-bits=10,10,12 2>&1 | FileCheck -check-prefix=CHECK2
// CHECK2: invalid value '10,10,12'
// RUN: %clang_cc1 %s -fsyntax-only -fupc-packed-bits=32,32 2>&1 | FileCheck -check-prefix=CHECK3
// CHECK3: invalid value '32,32'
// RUN: %clang_cc1 %s -fsyntax-only -fupc-packed-bits=err,32,32 2>&1 | FileCheck -check-prefix=CHECK4
// CHECK4: invalid value 'err,32,32'
// RUN: %clang_cc1 %s -fsyntax-only -fupc-packed-bits=32,err,32 2>&1 | FileCheck -check-prefix=CHECK5
// CHECK5: invalid value '32,err,32'
// RUN: %clang_cc1 %s -fsyntax-only -fupc-packed-bits=32,32,err 2>&1 | FileCheck -check-prefix=CHECK6
// CHECK6: invalid value '32,32,err'
