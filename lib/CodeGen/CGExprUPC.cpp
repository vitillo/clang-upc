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
