set(LLVM_NO_RTTI 1)

set(LLVM_USED_LIBS
    clangFrontend
    clangSerialization
    clangSema
    clangAST
    clangParse
    clangLex
    clangBasic
    )

set(LLVM_LINK_COMPONENTS
    jit
  )

add_clang_executable(ast-test
  ast-test.cpp
  )
add_dependencies(ast-test clang-headers)
