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

llvm::Value *CodeGenFunction::EmitUPCBitCastZeroPhase(llvm::Value *Value, QualType DestTy) {
  return EmitUPCPointer(llvm::ConstantInt::get(SizeTy, 0),
                        EmitUPCPointerGetThread(Value),
                        EmitUPCPointerGetAddr(Value));
}

llvm::Value *CodeGenFunction::EmitUPCNullPointer(QualType DestTy) {
  return EmitUPCPointer(llvm::ConstantInt::get(SizeTy, 0),
                        llvm::ConstantInt::get(SizeTy, 0),
                        llvm::ConstantInt::get(SizeTy, 0));
}

static const char * getUPCTypeID(CodeGenFunction& CGF,
                                 QualType *AccessTy,
                                 llvm::Type *Ty,
                                 uint64_t Size,
                                 uint64_t Align) {
  ASTContext &Context = CGF.getContext();
  const llvm::TargetData &Target = CGF.CGM.getTargetData();
  unsigned UnitWidth = Context.getCharWidth();

  if(Ty->isFloatTy()) {
    *AccessTy = Context.FloatTy;
    return "sf";
  } else if(Ty->isDoubleTy()) {
    *AccessTy = Context.DoubleTy;
    return "df";
  } else if(Ty->isX86_FP80Ty() || Ty->isFP128Ty() || Ty->isPPC_FP128Ty()) {
    *AccessTy = Context.LongDoubleTy;
    return "tf";
  }

  if (Size % UnitWidth == 0 &&
      Size / UnitWidth <= 16 &&
      Align % Target.getABIIntegerTypeAlignment(Size) == 0) {
    if (Size == Context.getTypeSize(Context.UnsignedCharTy)) {
      *AccessTy = Context.UnsignedCharTy;
    } else if (Size == Context.getTypeSize(Context.UnsignedShortTy)) {
      *AccessTy = Context.UnsignedShortTy;
    } else if (Size == Context.getTypeSize(Context.UnsignedIntTy)) {
      *AccessTy = Context.UnsignedIntTy;
    } else if (Size == Context.getTypeSize(Context.UnsignedLongTy)) {
      *AccessTy = Context.UnsignedLongTy;
    } else if (Size == Context.getTypeSize(Context.UnsignedLongLongTy)) {
      *AccessTy = Context.UnsignedLongLongTy;
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
  const llvm::TargetData &Target = CGM.getTargetData();
  uint64_t Size = Target.getTypeSizeInBits(DestLTy);
  uint64_t Align = Target.getABITypeAlignment(DestLTy);
  return EmitFromMemory(EmitUPCLoad(Addr, isStrict, DestLTy, Size, Align), Ty);
}

llvm::Value *CodeGenFunction::EmitUPCLoad(llvm::Value *Addr,
                                          bool isStrict,
                                          llvm::Type *LTy,
                                          uint64_t Size,
                                          uint64_t Align) {
  const ASTContext& Context = getContext();
  QualType ArgTy = Context.getPointerType(Context.getSharedType(Context.VoidTy));
  QualType ResultTy;
  llvm::SmallString<16> Name("__get");
  if (isStrict) Name += 's';

  if (const char * ID = getUPCTypeID(*this, &ResultTy, LTy, Size, Align)) {
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
    if (LTy->isPointerTy())
      Value = Builder.CreateIntToPtr(Value, LTy);
    else
      Value = Builder.CreateBitCast(Value, LTy);
    return Value;
  } else {
    // FIXME
  }
}

void CodeGenFunction::EmitUPCStore(llvm::Value *Value,
                                   llvm::Value *Addr,
                                   bool isStrict,
                                   QualType Ty) {
  llvm::Type *DestLTy = ConvertTypeForMem(Ty);
  const llvm::TargetData &Target = CGM.getTargetData();
  uint64_t Size = Target.getTypeSizeInBits(DestLTy);
  uint64_t Align = Target.getABITypeAlignment(DestLTy);
  return EmitUPCStore(EmitToMemory(Value, Ty), Addr, isStrict, Size, Align);
}

void CodeGenFunction::EmitUPCStore(llvm::Value *Value,
                                   llvm::Value *Addr,
                                   bool isStrict,
                                   uint64_t Size,
                                   uint64_t Align) {

  const ASTContext& Context = getContext();
  QualType AddrTy = Context.getPointerType(Context.getSharedType(Context.VoidTy));
  QualType ValTy;
  llvm::SmallString<16> Name("__put");
  if (isStrict) Name += 's';

  if (const char * ID = getUPCTypeID(*this, &ValTy, Value->getType(), Size, Align)) {
    Name += ID;
    Name += "2";

    llvm::Type *ValLTy = ConvertTypeForMem(ValTy);

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
      return Builder.CreateAnd(Val, llvm::APInt::getLowBitsSet(64, PhaseBits));
    } else {
      return Builder.CreateLShr(Val, ThreadBits + AddrBits);
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
      Val = Builder.CreateLShr(Val, PhaseBits);
    } else {
      Val = Builder.CreateLShr(Val, AddrBits);
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
      return Builder.CreateLShr(Val, ThreadBits + PhaseBits);
    } else {
      return Builder.CreateAnd(Val, llvm::APInt::getLowBitsSet(64, AddrBits));
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
      Val = Builder.CreateOr(Builder.CreateShl(Addr, ThreadBits + PhaseBits),
                             Builder.CreateOr(Builder.CreateShl(Thread, PhaseBits),
                                              Phase));
    } else {
      Val = Builder.CreateOr(Builder.CreateShl(Phase, ThreadBits + AddrBits),
                             Builder.CreateOr(Builder.CreateShl(Thread, AddrBits),
                                              Addr));
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

llvm::Constant *CodeGenModule::getUPCMyThread() {
  if (!UPCMyThread) {
    if (getModule().getNamedGlobal("MYTHREAD"))
      UPCMyThread = getModule().getOrInsertGlobal("MYTHREAD", IntTy);
    else
      UPCMyThread = new llvm::GlobalVariable(getModule(), IntTy, true,
                                             llvm::GlobalValue::ExternalLinkage, 0,
                                             "MYTHREAD");
  }
  return UPCMyThread;
}

llvm::Value *CodeGenFunction::EmitUPCThreads() {
  return Builder.CreateLoad(CGM.getUPCThreads());
}

llvm::Value *CodeGenFunction::EmitUPCMyThread() {
  return Builder.CreateLoad(CGM.getUPCMyThread());
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

llvm::Value *CodeGenFunction::EmitUPCPointerDiff(
    llvm::Value *Pointer1, llvm::Value *Pointer2, const Expr *E) {

  const BinaryOperator *expr = cast<BinaryOperator>(E);
  Expr *LHSOperand = expr->getLHS();
  QualType PtrTy = LHSOperand->getType();

  llvm::Value *Phase1 = EmitUPCPointerGetPhase(Pointer1);
  llvm::Value *Thread1 = EmitUPCPointerGetThread(Pointer1);
  llvm::Value *Addr1 = EmitUPCPointerGetAddr(Pointer1);

  llvm::Value *Phase2 = EmitUPCPointerGetPhase(Pointer2);
  llvm::Value *Thread2 = EmitUPCPointerGetThread(Pointer2);
  llvm::Value *Addr2 = EmitUPCPointerGetAddr(Pointer2);

  QualType PointeeTy = PtrTy->getAs<PointerType>()->getPointeeType();
  QualType ElemTy = PointeeTy;
  while (const ArrayType *AT = getContext().getAsArrayType(ElemTy))
    ElemTy = AT->getElementType();
  Qualifiers Quals = ElemTy.getQualifiers();

  llvm::Constant *ElemSize = 
    llvm::ConstantInt::get(SizeTy, getContext().getTypeSize(ElemTy));
  llvm::Value *AddrByteDiff = Builder.CreateSub(Addr1, Addr2, "addr.diff");
  llvm::Value *AddrDiff = Builder.CreateExactSDiv(AddrByteDiff, ElemSize);

  llvm::Value *Result;

  if (Quals.getLayoutQualifier() == 0) {
    Result = AddrDiff;
  } else {
    llvm::Constant *B = llvm::ConstantInt::get(SizeTy, Quals.getLayoutQualifier());
    llvm::Value *Threads = Builder.CreateZExt(EmitUPCThreads(), SizeTy);

    llvm::Value *ThreadDiff = Builder.CreateMul(Builder.CreateSub(Thread1, Thread2, "thread.diff"), B);
    llvm::Value *PhaseDiff = Builder.CreateSub(Phase1, Phase2, "phase.diff");
    llvm::Value *BlockDiff =
      Builder.CreateMul(Builder.CreateSub(AddrDiff, PhaseDiff), Threads, "block.diff");

    Result = Builder.CreateAdd(BlockDiff, Builder.CreateMul(ThreadDiff, PhaseDiff), "ptr.diff");
  }

  // FIXME: Divide by the array dimension
  return Result;
}

llvm::Value *CodeGenFunction::EmitUPCPointerCompare(
    llvm::Value *Pointer1, llvm::Value *Pointer2, const BinaryOperator *E) {

  QualType PtrTy = E->getLHS()->getType();

  QualType PointeeTy = PtrTy->getAs<PointerType>()->getPointeeType();
  QualType ElemTy = PointeeTy;
  while (const ArrayType *AT = getContext().getAsArrayType(ElemTy))
    ElemTy = AT->getElementType();
  Qualifiers Quals = ElemTy.getQualifiers();

  // Use the standard transformations so we only
  // have to implement < and ==.
  bool Flip = false;
  switch (E->getOpcode()) {
  case BO_EQ: break;
  case BO_NE: Flip = true; break;
  case BO_LT: break;
  case BO_GT: std::swap(Pointer1, Pointer2); break;
  case BO_LE: std::swap(Pointer1, Pointer2); Flip = true; break;
  case BO_GE: Flip = true; break;
  default: llvm_unreachable("expected a comparison operator");
  }

  llvm::Value *Phase1 = EmitUPCPointerGetPhase(Pointer1);
  llvm::Value *Thread1 = EmitUPCPointerGetThread(Pointer1);
  llvm::Value *Addr1 = EmitUPCPointerGetAddr(Pointer1);

  llvm::Value *Phase2 = EmitUPCPointerGetPhase(Pointer2);
  llvm::Value *Thread2 = EmitUPCPointerGetThread(Pointer2);
  llvm::Value *Addr2 = EmitUPCPointerGetAddr(Pointer2);

  llvm::Value *Result;
  // Equality has to work correctly even if the pointers
  // are not in the same array.
  if (E->getOpcode() == BO_EQ || E->getOpcode() == BO_NE) {
    Result = Builder.CreateAnd(Builder.CreateICmpEQ(Addr1, Addr2),
                               Builder.CreateICmpEQ(Thread1, Thread2));
  } else if (Quals.getLayoutQualifier() == 0) {
    Result = Builder.CreateICmpULT(Addr1, Addr2);
  } else {
    llvm::IntegerType *BoolTy = llvm::Type::getInt1Ty(CGM.getLLVMContext());
    llvm::Constant *LTResult = llvm::ConstantInt::get(BoolTy, 1);
    llvm::Constant *GTResult = llvm::ConstantInt::get(BoolTy, 0);

    llvm::Constant *ElemSize = 
      llvm::ConstantInt::get(SizeTy, getContext().getTypeSize(ElemTy));
    llvm::Value *AddrByteDiff = Builder.CreateSub(Addr1, Addr2, "addr.diff");
    llvm::Value *PhaseDiff = Builder.CreateSub(Phase1, Phase2, "phase.diff");
    llvm::Value *PhaseByteDiff = Builder.CreateMul(PhaseDiff, ElemSize);
    llvm::Value *TestBlockLT = Builder.CreateICmpSLT(AddrByteDiff, PhaseByteDiff);
    llvm::Value *TestBlockEQ = Builder.CreateICmpEQ(AddrByteDiff, PhaseByteDiff);
    llvm::Value *TestThreadLT = Builder.CreateICmpULT(Thread1, Thread2);
    llvm::Value *TestThreadEQ = Builder.CreateICmpEQ(Thread1, Thread2);
    
    // Compare the block first, then the thread, then the phase
    Result = Builder.CreateSelect(TestBlockLT,
      LTResult,
      Builder.CreateSelect(TestBlockEQ,
        Builder.CreateSelect(TestThreadLT,
          LTResult,
          Builder.CreateSelect(TestThreadEQ,
            Builder.CreateICmpULT(Phase1, Phase2),
            GTResult)),
        GTResult));
  }

  if (Flip)
    Result = Builder.CreateNot(Result);
  return Result;
}

llvm::Value *CodeGenFunction::EmitUPCFieldOffset(llvm::Value *Addr,
                                                 llvm::Type * StructTy,
                                                 int Idx) {
  const llvm::StructLayout * Layout =
    CGM.getTargetData().getStructLayout(cast<llvm::StructType>(StructTy));
  llvm::Value * Offset =
    llvm::ConstantInt::get(SizeTy, Layout->getElementOffset(Idx));
  return EmitUPCPointer(
    llvm::ConstantInt::get(SizeTy, 0),
    EmitUPCPointerGetThread(Addr),
    Builder.CreateAdd(EmitUPCPointerGetAddr(Addr), Offset));
}

llvm::Value *CodeGenFunction::EmitUPCPointerAdd(llvm::Value *Addr,
                                                int Idx) {
  llvm::Value * Offset =
    llvm::ConstantInt::get(SizeTy, Idx);
  return EmitUPCPointer(
    llvm::ConstantInt::get(SizeTy, 0),
    EmitUPCPointerGetThread(Addr),
    Builder.CreateAdd(EmitUPCPointerGetAddr(Addr), Offset));
}
