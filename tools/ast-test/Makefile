##===- tools/ast-test/Makefile -----------------*- Makefile -*-===##
#
#                     The LLVM Compiler Infrastructure
#
# This file is distributed under the University of Illinois Open Source
# License. See LICENSE.TXT for details.
#
##===----------------------------------------------------------------------===##

CLANG_LEVEL := ../..

TOOLNAME = ast-test

# No plugins, optimize startup time.
TOOL_NO_EXPORTS = 1

LINK_COMPONENTS := jit
USEDLIBS = clangFrontend.a clangDriver.a clangSerialization.a \
           clangParse.a clangSema.a clangAnalysis.a clangAST.a  \
	   clangLex.a clangBasic.a

include $(CLANG_LEVEL)/Makefile
