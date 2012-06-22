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
#include "llvm/Target/TargetData.h"
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

static const char * getUPCTypeID(CodeGenFunction& CGF, QualType &Ty) {
  ASTContext &Context = CGF.getContext();
  const llvm::TargetData &Target = CGF.CGM.getTargetData();
  unsigned UnitWidth = Context.getCharWidth();
  llvm::Type * LTy = CGF.ConvertType(Ty);

  uint64_t Size = Target.getTypeSizeInBits(LTy);
  uint64_t Align = Target.getABITypeAlignment(LTy);

  if(Ty == Context.FloatTy) {
    return "sf";
  } else if(Ty == Context.DoubleTy) {
    return "df";
  } else if(Ty == Context.LongDoubleTy) {
    return "tf";
  }

  if (Size % UnitWidth == 0 &&
      Size / UnitWidth <= 16 &&
      Align % Target.getABIIntegerTypeAlignment(Size) == 0) {
    if (Size == Context.getTypeSize(Context.UnsignedCharTy)) {
      Ty = Context.UnsignedCharTy;
    } else if (Size == Context.getTypeSize(Context.UnsignedShortTy)) {
      Ty = Context.UnsignedShortTy;
    } else if (Size == Context.getTypeSize(Context.UnsignedIntTy)) {
      Ty = Context.UnsignedIntTy;
    } else if (Size == Context.getTypeSize(Context.UnsignedLongTy)) {
      Ty = Context.UnsignedLongTy;
    } else if (Size == Context.getTypeSize(Context.UnsignedLongLongTy)) {
      Ty = Context.UnsignedLongLongTy;
    } else {
      return 0;
    }
    switch (Size / UnitWidth) {
    case 1: return "qi";
    case 2: return "hi";
    case 4: return "si";
    case 8: return "di";
    case 16: return "ti";
    default: return 0;
    }
  }

  return 0;
}

llvm::Value *CodeGenFunction::EmitUPCLoad(llvm::Value *Addr, bool isStrict, QualType Ty) {
  llvm::Type *DestLTy = ConvertTypeForMem(Ty);

  const ASTContext& Context = getContext();
  QualType ArgTy = Context.getPointerType(Context.getSharedType(Context.VoidTy));
  QualType ResultTy = Ty->getCanonicalTypeUnqualified();
  llvm::SmallString<16> Name("__get");
  if (isStrict) Name += 's';

  if (const char * ID = getUPCTypeID(*this, ResultTy)) {
    Name += ID;
    Name += "2";

    CallArgList Args;
    Args.add(RValue::get(Addr), ArgTy);
    QualType ArgTypes[] = { ArgTy };
    QualType FuncType = Context.getFunctionType(ResultTy, ArgTypes, 1, FunctionProtoType::ExtProtoInfo());
    const CGFunctionInfo &Info = getTypes().arrangeFunctionCall(Args, FuncType->castAs<FunctionType>());
    llvm::FunctionType * FTy = cast<llvm::FunctionType>(ConvertType(FuncType));
    llvm::Value * Fn = CGM.CreateRuntimeFunction(FTy, Name);

    RValue Result = EmitCall(Info, Fn, ReturnValueSlot(), Args);
    llvm::Value *Value = Result.getScalarVal();
    if (DestLTy->isPointerTy())
      Value = Builder.CreateIntToPtr(Value, DestLTy);
    else
      Value = Builder.CreateBitCast(Value, DestLTy);
    return EmitFromMemory(Value, Ty);
  } else {
    // FIXME
  }
}

void CodeGenFunction::EmitUPCStore(llvm::Value *Value, llvm::Value *Addr, bool isStrict, QualType Ty) {

  const ASTContext& Context = getContext();
  QualType AddrTy = Context.getPointerType(Context.getSharedType(Context.VoidTy));
  QualType ValTy = Ty->getCanonicalTypeUnqualified();
  llvm::SmallString<16> Name("__put");
  if (isStrict) Name += 's';

  if (const char * ID = getUPCTypeID(*this, ValTy)) {
    Name += ID;
    Name += "2";

    llvm::Type *ValLTy = ConvertTypeForMem(ValTy);

    Value = EmitToMemory(Value, Ty);
    if (Value->getType()->isPointerTy())
      Value = Builder.CreatePtrToInt(Value, ValLTy);
    else
      Value = Builder.CreateBitCast(Value, ValLTy);

    CallArgList Args;
    Args.add(RValue::get(Addr), AddrTy);
    Args.add(RValue::get(Value), ValTy);
    QualType ArgTypes[] = { AddrTy, ValTy };
    QualType FuncType = Context.getFunctionType(Context.VoidTy, ArgTypes, 2, FunctionProtoType::ExtProtoInfo());
    const CGFunctionInfo &Info = getTypes().arrangeFunctionCall(Args, FuncType->castAs<FunctionType>());
    llvm::FunctionType * FTy = cast<llvm::FunctionType>(ConvertType(FuncType));
    llvm::Value * Fn = CGM.CreateRuntimeFunction(FTy, Name);

    EmitCall(Info, Fn, ReturnValueSlot(), Args);
  } else {
    // FIXME
  }
}

void CodeGenFunction::EmitUPCAggregateCopy(llvm::Value *Dest, llvm::Value *Src,
                                           QualType DestTy, QualType SrcTy) {
  const ASTContext& Context = getContext();
  QualType ArgTy = Context.getPointerType(Context.getSharedType(Context.VoidTy));
  QualType SizeType = Context.getSizeType();
  assert(DestTy->getCanonicalTypeUnqualified() == SrcTy->getCanonicalTypeUnqualified());
  llvm::Constant *Len =
    llvm::ConstantInt::get(ConvertType(SizeType),
                           Context.getTypeSizeInChars(DestTy).getQuantity());
  llvm::SmallString<16> Name;
  const char *OpName;
  QualType DestArgTy, SrcArgTy;
  if (DestTy.getQualifiers().hasShared() && SrcTy.getQualifiers().hasShared()) {
    // both shared
    OpName = "copy";
    DestArgTy = SrcArgTy = ArgTy;
  } else if (DestTy.getQualifiers().hasShared()) {
    OpName = "put";
    DestArgTy = ArgTy;
    SrcArgTy = Context.VoidPtrTy;
  } else if (SrcTy.getQualifiers().hasShared()) {
    OpName = "get";
    DestArgTy = Context.VoidPtrTy;
    SrcArgTy = ArgTy;
  } else {
    llvm_unreachable("expected at least one shared argument");
  }

  Name += "__";
  Name += OpName;
  if (DestTy.getQualifiers().hasStrict() || SrcTy.getQualifiers().hasStrict())
    Name += 's';
  Name += "blk3";
  CallArgList Args;
  Args.add(RValue::get(Dest), DestArgTy);
  Args.add(RValue::get(Src), SrcArgTy);
  Args.add(RValue::get(Len), SizeType);
  QualType ArgTypes[] = { DestArgTy, SrcArgTy, SizeType };
  QualType FuncType = Context.getFunctionType(Context.VoidTy, ArgTypes, 3, FunctionProtoType::ExtProtoInfo());
  const CGFunctionInfo &Info = getTypes().arrangeFunctionCall(Args, FuncType->castAs<FunctionType>());
  llvm::FunctionType * FTy = cast<llvm::FunctionType>(ConvertType(FuncType));
  llvm::Value * Fn = CGM.CreateRuntimeFunction(FTy, Name);
  EmitCall(Info, Fn, ReturnValueSlot(), Args);

}

llvm::Value *CodeGenFunction::EmitUPCPointerGetPhase(llvm::Value *Pointer) {
  const LangOptions& LangOpts = getContext().getLangOpts();
  unsigned PhaseBits = LangOpts.UPCPhaseBits;
  unsigned ThreadBits = LangOpts.UPCThreadBits;
  unsigned AddrBits = LangOpts.UPCAddrBits;
  if (PhaseBits + ThreadBits + AddrBits == 64) {
    llvm::Value *Val = Builder.CreateExtractValue(Pointer, 0);
    if (/*addr first*/true) {
      return Builder.CreateLShr(Val, ThreadBits + AddrBits);
    } else {
      return Builder.CreateAnd(Val, llvm::APInt::getLowBitsSet(64, PhaseBits));
    }
  } else {
    if (/*addr first*/true) {
      return Builder.CreateZExt(Builder.CreateExtractValue(Pointer, 2), Int64Ty);
    } else {
      return Builder.CreateZExt(Builder.CreateExtractValue(Pointer, 0), Int64Ty);
    }
  }
}

llvm::Value *CodeGenFunction::EmitUPCPointerGetThread(llvm::Value *Pointer) {
  const LangOptions& LangOpts = getContext().getLangOpts();
  unsigned PhaseBits = LangOpts.UPCPhaseBits;
  unsigned ThreadBits = LangOpts.UPCThreadBits;
  unsigned AddrBits = LangOpts.UPCAddrBits;
  if (PhaseBits + ThreadBits + AddrBits == 64) {
    llvm::Value *Val = Builder.CreateExtractValue(Pointer, 0);
    if (/*addr first*/true) {
      Val = Builder.CreateLShr(Val, AddrBits);
    } else {
      Val = Builder.CreateLShr(Val, PhaseBits);
    }
    return Builder.CreateAnd(Val, llvm::APInt::getLowBitsSet(64, ThreadBits));
  } else {
    return Builder.CreateZExt(Builder.CreateExtractValue(Pointer, 1), Int64Ty);
  }
}

llvm::Value *CodeGenFunction::EmitUPCPointerGetAddr(llvm::Value *Pointer) {
  const LangOptions& LangOpts = getContext().getLangOpts();
  unsigned PhaseBits = LangOpts.UPCPhaseBits;
  unsigned ThreadBits = LangOpts.UPCThreadBits;
  unsigned AddrBits = LangOpts.UPCAddrBits;
  if (PhaseBits + ThreadBits + AddrBits == 64) {
    llvm::Value *Val = Builder.CreateExtractValue(Pointer, 0);
    if (/*addr first*/true) {
      return Builder.CreateAnd(Val, llvm::APInt::getLowBitsSet(64, AddrBits));
    } else {
      return Builder.CreateLShr(Val, ThreadBits + PhaseBits);
    }
  } else {
    if (/*addr first*/true) {
      return Builder.CreateExtractValue(Pointer, 0);
    } else {
      return Builder.CreateExtractValue(Pointer, 2);
    }
  }
}

llvm::Value *CodeGenFunction::EmitUPCPointer(llvm::Value *Phase, llvm::Value *Thread, llvm::Value *Addr) {
  const LangOptions& LangOpts = getContext().getLangOpts();
  unsigned PhaseBits = LangOpts.UPCPhaseBits;
  unsigned ThreadBits = LangOpts.UPCThreadBits;
  unsigned AddrBits = LangOpts.UPCAddrBits;
  llvm::Value *Result = llvm::UndefValue::get(GenericPtsTy);
  if (PhaseBits + ThreadBits + AddrBits == 64) {
    llvm::Value *Val;
    if (/*addr first*/true) {
      Val = Builder.CreateOr(Builder.CreateShl(Phase, ThreadBits + AddrBits),
                             Builder.CreateOr(Builder.CreateShl(Thread, AddrBits),
                                              Addr));
    } else {
      Val = Builder.CreateOr(Builder.CreateShl(Addr, ThreadBits + PhaseBits),
                             Builder.CreateOr(Builder.CreateShl(Thread, AddrBits),
                                              Phase));
    }
    Result = Builder.CreateInsertValue(Result, Val, 0);
  } else {
    Phase = Builder.CreateTrunc(Phase, Int32Ty);
    Thread = Builder.CreateTrunc(Thread, Int32Ty);
    if (/*addr first*/true) {
      Result = Builder.CreateInsertValue(Result, Addr, 0);
      Result = Builder.CreateInsertValue(Result, Thread, 1);
      Result = Builder.CreateInsertValue(Result, Phase, 2);
    } else {
      Result = Builder.CreateInsertValue(Result, Phase, 0);
      Result = Builder.CreateInsertValue(Result, Thread, 1);
      Result = Builder.CreateInsertValue(Result, Addr, 2);
    }
  }
  return Result;
}

llvm::Constant *CodeGenModule::getUPCThreads() {
  if (!UPCThreads) {
    if (getModule().getNamedGlobal("THREADS"))
      UPCThreads = getModule().getOrInsertGlobal("THREADS", IntTy);
    else
      UPCThreads = new llvm::GlobalVariable(getModule(), IntTy, true,
                                            llvm::GlobalValue::ExternalLinkage, 0,
                                            "THREADS");
  }
  return UPCThreads;
}

llvm::Value *CodeGenFunction::EmitUPCThreads() {
  return Builder.CreateLoad(CGM.getUPCThreads());
}

llvm::Value *CodeGenFunction::EmitUPCPointerArithmetic(
    llvm::Value *Pointer, llvm::Value *Index, QualType PtrTy, const Expr *E, bool IsSubtraction) {

  const BinaryOperator *expr = cast<BinaryOperator>(E);
  Expr *pointerOperand = expr->getLHS();
  Expr *indexOperand = expr->getRHS();

  if (!IsSubtraction && !Index->getType()->isIntegerTy()) {
    std::swap(Pointer, Index);
    std::swap(pointerOperand, indexOperand);
  }
  llvm::Value *Phase = EmitUPCPointerGetPhase(Pointer);
  llvm::Value *Thread = EmitUPCPointerGetThread(Pointer);
  llvm::Value *Addr = EmitUPCPointerGetAddr(Pointer);

  QualType PointeeTy = PtrTy->getAs<PointerType>()->getPointeeType();
  QualType ElemTy = PointeeTy;
  while (const ArrayType *AT = getContext().getAsArrayType(ElemTy))
    ElemTy = AT->getElementType();
  Qualifiers Quals = ElemTy.getQualifiers();

  unsigned width = cast<llvm::IntegerType>(Index->getType())->getBitWidth();
  if (width != PointerWidthInBits) {
    // Zero-extend or sign-extend the pointer value according to
    // whether the index is signed or not.
    bool isSigned = indexOperand->getType()->isSignedIntegerOrEnumerationType();
    Index = Builder.CreateIntCast(Index, PtrDiffTy, isSigned,
                                      "idx.ext");
  }

  if (IsSubtraction)
    Index = Builder.CreateNeg(Index);

  if (Quals.getLayoutQualifier() == 0) {
    // UPC 1.2 6.4.2p2
    // If the shared array is declared with indefinite block size,
    // the result of the pointer-to-shared arithmetic is identical
    // to that described for normal C pointers in [IOS/IEC00 Sec 6.5.2]
    // except that the thread of the new pointer shall be the
    // same as that of the original pointer and the phase
    // component is defined to always be zero.

    Addr = Builder.CreateAdd(Addr, Index, "add.addr");
  } else {
    llvm::Value *OldPhase = Phase;
    llvm::Constant *B = llvm::ConstantInt::get(SizeTy, Quals.getLayoutQualifier());
    llvm::Value *Threads = Builder.CreateZExt(EmitUPCThreads(), SizeTy);
    llvm::Value *GlobalBlockSize = Builder.CreateNUWMul(Threads, B);
    // Combine the Phase and Thread into a single unit
    llvm::Value *TmpPhaseThread =
      Builder.CreateNUWAdd(Builder.CreateNUWMul(Thread, B),
                           Phase);

    TmpPhaseThread = Builder.CreateAdd(TmpPhaseThread, Index);

    // Div is the number of (B * THREADS) blocks that we need to jump
    // Rem is Thread * B + Phase
    llvm::Value *Div = Builder.CreateSRem(TmpPhaseThread, GlobalBlockSize);
    llvm::Value *Rem = Builder.CreateSDiv(TmpPhaseThread, GlobalBlockSize);
    // Fix the result of the division/modulus
    llvm::Value *Test = Builder.CreateICmpSLT(Rem, llvm::ConstantInt::get(SizeTy, 0));
    Rem = Builder.CreateSelect(Test, Builder.CreateAdd(Rem, GlobalBlockSize), Rem);
    llvm::Value *DecDiv = Builder.CreateSub(Div, llvm::ConstantInt::get(SizeTy, 1));
    Div = Builder.CreateSelect(Test, DecDiv, Div);

    // Split out the Phase and Thread components
    Thread = Builder.CreateUDiv(Rem, B);
    Phase = Builder.CreateURem(Rem, B);

    // Compute the final Addr.
    llvm::Value *AddrInc =
      Builder.CreateMul(Builder.CreateAdd(Builder.CreateSub(Phase, OldPhase),
                                          Builder.CreateMul(Div, B)),
                        llvm::ConstantInt::get(SizeTy, getContext().getTypeSize(ElemTy)));
    Addr = Builder.CreateAdd(Addr, AddrInc);
  }

  return EmitUPCPointer(Phase, Thread, Addr);
}
