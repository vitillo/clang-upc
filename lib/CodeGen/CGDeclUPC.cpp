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
  if(!InitExpr)
    return 0;

  // indefinite block size: emit as normal array
  if (Quals.hasLayoutQualifier() &&
      Quals.getLayoutQualifier() == 0)
    return 0;

  ErrorUnsupported(InitD, "initialization of shared array");


  // clone original array initialization into new non-shared symbol
  ASTContext &Ctx = getContext();
  IdentifierInfo *name = &Ctx.Idents.get(VD->getNameAsString() + "__source");
  // really i just want to remove shared but can't figure out how to do that?
  Qualifiers Q;
  QualType NonSharedType = Ctx.getUnqualifiedArrayType(VD->getType(), Q);
  VarDecl *InitD = VarDecl::Create(Ctx, const_cast<DeclContext*>(
                                                                 VD->getDeclContext()),
                                   VD->getLocStart(), VD->getLocation(),
                                   name, NonSharedType,
                                   Ctx.getTrivialTypeSourceInfo(VD->getType(), 
                                                                VD->getLocation()),
                                   SC_Static, SC_Static);
  InitD->setInit(const_cast<Expr*>(InitExpr)); // should clone instead?
  EmitGlobalVarDefinition(InitD);
  llvm::Constant *Source = GetAddrOfGlobalVar(InitD);

  // generalization of stuff from ExprConstant.cpp (refactor?)
  bool hasTHREADS = false;
  uint64_t ArrayDim = 1;
  SmallVector<llvm::Constant *, 64> Dims;
  while (isa<ArrayType>(CurTy.getTypePtr())) {
    if (const ConstantArrayType *CAT = dyn_cast<ConstantArrayType>(CurTy.getTypePtr())) {
      uint64_t Dim = CAT->getSize().getZExtValue();
      ArrayDim *= Dim;
      Dims.push_back(llvm::ConstantInt::get(Int64Ty, Dim));
    } else if (const UPCThreadArrayType *TAT = dyn_cast<UPCThreadArrayType>(CurTy.getTypePtr())) {
      uint64_t Dim = TAT->getSize().getZExtValue();
      ArrayDim *= Dim;
      if (TAT->getThread())
        hasTHREADS = true;
      Dims.push_back(llvm::ConstantInt::get(Int64Ty, Dim));
    }
    CurTy = cast<ArrayType>(CurTy.getTypePtr())->getElementType();
  }

  uint32_t BlockSize = Quals.hasLayoutQualifier()?
    Quals.getLayoutQualifier() : uint32_t(1);

  uint64_t LocalElements;
  if (hasTHREADS)
    ErrorUnsupported(InitD, "initialization of shared array in dynamic THREADS environment");
    //LocalElements = (ArrayDim + BlockSize - 1) / BlockSize * BlockSize;

  uint32_t NThreads = Ctx.getLangOpts().UPCThreads;
  if (NThreads == 0) {
    NThreads = 1;
  }
  uint64_t Div = BlockSize * NThreads;
  LocalElements = ((ArrayDim + Div - 1) / Div * BlockSize);

  // now create the local slice of the shared array
  llvm::APInt NumElements(Ctx.getTypeSize(Ctx.getSizeType()), LocalElements);
  QualType LocalArrayType = Ctx.getConstantArrayType(CurTy, NumElements,
                                                     ArrayType::Normal, 0);

  const InitListExpr *OldList = dyn_cast<InitListExpr>(InitExpr);
  QualType ElementType = OldList->getInit(0)->getType();


  SmallVector<llvm::Constant *, 64> Inits;
  for (uint64_t I = 0; I != LocalElements; ++I) {
    uint64_t J = (I/BlockSize)*NThreads*BlockSize + I % BlockSize;
    uint64_t K = (I/BlockSize + 1)*BlockSize;
    llvm::Constant *JInt = llvm::ConstantInt::get(Int64Ty, J);
    llvm::Constant *KInt = llvm::ConstantInt::get(Int64Ty, K);
    // calculate absolute index, ignoring dimensions, then derive 
    // individual indices from that
    llvm::Constant *AbsInd = 
      llvm::ConstantExpr::getAdd(JInt,
                                 llvm::ConstantExpr::getMul(KInt,CGF.EmitUPCMyThread())); // CGF!
    SmallVector<llvm::Constant *, 64> Indices;
    Indices.resize(Dims.size());
    for(int D = Dims.size()-1; D>=0; --D) {
      Indices[D] = llvm::ConstantExpr::getURem(AbsInd, Dims[D]);
      AbsInd = llvm::ConstantExpr::getUDiv(AbsInd, Dims[D]);
    }
    llvm::Constant *Init = llvm::ConstantExpr::getGetElementPtr(Source, Indices);
    Inits.push_back(Init);
  }

  llvm::ArrayType *ArrayType = llvm::ArrayType::get(getTypes().ConvertType(ElementType), LocalElements);
  return llvm::ConstantArray::get(ArrayType, Inits);
}
