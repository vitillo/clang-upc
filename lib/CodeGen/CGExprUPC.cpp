//===--- CGExprUPC.cpp - Emit LLVM Code for UPC expressions ---------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This contains code dealing with code generation of UPC expressions
//
//===----------------------------------------------------------------------===//

#include "CodeGenFunction.h"
using namespace clang;
using namespace CodeGen;

static llvm::Constant *getUPCGetAddrFn(CodeGenFunction &CGF) {
  // void *__getaddr(shared void * ptr);
  
  llvm::Type *Int8PtrTy = CGF.Int8PtrTy;
  llvm::Type *GenericPtsTy = CGF.GenericPtsTy;

  llvm::Type *Args[] = { GenericPtsTy };
  
  llvm::FunctionType *FTy =
    llvm::FunctionType::get(Int8PtrTy, Args, false);
  
  return CGF.CGM.CreateRuntimeFunction(FTy, "__getaddr");
}

llvm::Value *CodeGenFunction::EmitUPCCastSharedToLocal(llvm::Value *Value, QualType DestTy) {
  llvm::Type *SrcLTy = GenericPtsTy;
  llvm::Type *DestLTy = ConvertType(DestTy);

  Value = Builder.CreateBitCast(Value, SrcLTy);
  Value = Builder.CreateCall(getUPCGetAddrFn(*this), Value);
  Value = Builder.CreateBitCast(Value, DestLTy);

  return Value;
}
