// RUN: %ast_test %s

int foo() {
  int i = 10;    // expected-decl-type{{int}}
  return i;
}

// The currently supported AST expectations.  If more need to be added,
// see tools/ast-test/ast-test.cpp.
//
//   attribute                look for attributes (ex: Used, Deprecated, etc.)
//   decl-kind                the Clang declarator kind (ex: CXXMethod)
//   decl-name                the C/C++ declarator name
//   no-return                has __declspec(noreturn)? (use empty match text)
//   thread-specified         is thread-local? (use empty match text)
//   stmt-class-name          statement class name (ex: CallExpr)
//                            this refers to the Clang class name for the Stmt
//   decl-type                C/C++ declaration type
//   expr-type                C/C++ expression type
//   return-type              C/C++ function return type
//   virtual-function         is virtual function? (use empty match text)
