//===--- CGDeclUPC.cpp - Emit LLVM Code from ASTs for UPC constructs ------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This coordinates the per-module state used while generating code.
//
//===----------------------------------------------------------------------===//

#include "CodeGenModule.h"
#include "llvm/DerivedTypes.h"
#include "llvm/Constants.h"

using namespace clang;
using namespace CodeGen;

// we need to generate an array that's just the local size of the shared array
// and initialize it with just the members that belong to the current thread
llvm::Constant *CodeGenModule::MaybeEmitUPCSharedArrayInits(const VarDecl *VD) {
  QualType SrcTy = VD->getType();
  QualType CurTy = SrcTy.getCanonicalType();
  Qualifiers Quals = SrcTy.getQualifiers();

  const Expr *InitExpr = VD->getAnyInitializer();
  if(InitExpr) {
    ErrorUnsupported(VD, "initialization of shared array");
    return 0;
  }

  // indefinite block size: emit as normal array
  if (Quals.hasLayoutQualifier() &&
      Quals.getLayoutQualifier() == 0)
    return 0;

  ASTContext &Ctx = getContext();

  // from localsizeof in AST/ExprConstant.cpp (refactor?)
  bool hasTHREADS = false;
  uint64_t ArrayDim = 1;
  while (isa<ArrayType>(CurTy.getTypePtr())) {
    if (const ConstantArrayType *CAT = dyn_cast<ConstantArrayType>(CurTy.getTypePtr()))
      ArrayDim *= CAT->getSize().getZExtValue();
    else if (const UPCThreadArrayType *TAT = dyn_cast<UPCThreadArrayType>(CurTy.getTypePtr())) {
      ArrayDim *= TAT->getSize().getZExtValue();
      if (TAT->getThread())
        hasTHREADS = true;
    }
    CurTy = cast<ArrayType>(CurTy.getTypePtr())->getElementType();
  }

  uint32_t BlockSize = Quals.hasLayoutQualifier()?
    Quals.getLayoutQualifier() : uint32_t(1);

  uint64_t LocalElements;
  if (hasTHREADS) {
    LocalElements = (ArrayDim + BlockSize - 1) / BlockSize * BlockSize;
  }
  else {
    uint32_t NThreads = Ctx.getLangOpts().UPCThreads;
    if (NThreads == 0) {
      NThreads = 1;
    }
    uint64_t Div = BlockSize * NThreads;
    LocalElements = ((ArrayDim + Div - 1) / Div * BlockSize);
  }

  // now create the local slice of the shared array
  llvm::APInt NumElements(Ctx.getTypeSize(Ctx.getSizeType()), LocalElements);
  QualType LocalArrayType = Ctx.getConstantArrayType(CurTy, NumElements,
                                                     ArrayType::Normal, 0);

  return EmitNullConstant(LocalArrayType);
}
