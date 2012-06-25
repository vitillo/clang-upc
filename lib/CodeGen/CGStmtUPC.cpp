//===--- CGStmtUPC.cpp - Emit LLVM Code from Statements -------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This contains code to emit UPC Stmt nodes as LLVM code.
//
//===----------------------------------------------------------------------===//

#include "CodeGenModule.h"
#include "CodeGenFunction.h"
#include "clang/AST/Stmt.h"
#include "llvm/Support/CallSite.h"
using namespace clang;
using namespace CodeGen;

void CodeGenFunction::EmitUPCNotifyStmt(const UPCNotifyStmt &S) {
  const Expr *E = S.getIdValue();
  llvm::Value *Id = E ? EmitScalarExpr(E) : llvm::ConstantInt::get(IntTy, 0x80000000);
  llvm::FunctionType *FTy = llvm::FunctionType::get(VoidTy, IntTy, false);
  EmitCallOrInvoke(CGM.CreateRuntimeFunction(FTy, "__upc_notify"), Id);
}

void CodeGenFunction::EmitUPCWaitStmt(const UPCWaitStmt &S) {
  const Expr *E = S.getIdValue();
  llvm::Value *Id = E ? EmitScalarExpr(E) : llvm::ConstantInt::get(IntTy, 0x80000000);
  llvm::FunctionType *FTy = llvm::FunctionType::get(VoidTy, IntTy, false);
  EmitCallOrInvoke(CGM.CreateRuntimeFunction(FTy, "__upc_wait"), Id);
}

void CodeGenFunction::EmitUPCBarrierStmt(const UPCBarrierStmt &S) {
  const Expr *E = S.getIdValue();
  llvm::Value *Id = E ? EmitScalarExpr(E) : llvm::ConstantInt::get(IntTy, 0x80000000);
  llvm::FunctionType *FTy = llvm::FunctionType::get(VoidTy, IntTy, false);
  EmitCallOrInvoke(CGM.CreateRuntimeFunction(FTy, "__upc_barrier"), Id);
}

static llvm::Value *EmitUPCFenceVar(CodeGenFunction &CGF) {
  // FIXME: Once we have support for shared variables
  // with static storage duration, create a real variable.
  const ASTContext &Ctx = CGF.getContext();
  return CGF.EmitUPCNullPointer(Ctx.getPointerType(Ctx.getSharedType(Ctx.IntTy)));
}

void CodeGenFunction::EmitUPCFenceStmt(const UPCFenceStmt &S) {
  llvm::Value *FencePtr = EmitUPCFenceVar(*this);
  llvm::Value *Val = EmitUPCLoad(FencePtr, /*strict*/true, getContext().IntTy);
  EmitUPCStore(Val, FencePtr, /*strict*/true, getContext().IntTy);
}

void CodeGenFunction::EmitUPCForAllStmt(const UPCForAllStmt &S) {
  assert(!"not implemented");
}
