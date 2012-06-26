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
#include "llvm/Constants.h"
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
  llvm::Value *Val = EmitUPCLoad(FencePtr, /*strict*/true, getContext().IntTy, S.getFenceLoc());
  EmitUPCStore(Val, FencePtr, /*strict*/true, getContext().IntTy, S.getFenceLoc());
}

llvm::Constant *getUPCForAllDepth(CodeGenModule& CGM) {
  return CGM.getModule().getOrInsertGlobal("__upc_forall_depth", CGM.IntTy);
}

namespace {

  struct UPCForAllCleanup : EHScopeStack::Cleanup {
    explicit UPCForAllCleanup(llvm::Value *D) : Depth(D) {  }
    virtual void Emit(CodeGenFunction &CGF, Flags flags) {
      CGF.Builder.CreateStore(Depth, getUPCForAllDepth(CGF.CGM));
    }
    llvm::Value *Depth;
  };

}

void CodeGenFunction::EmitUPCForAllStmt(const UPCForAllStmt &S) {
  JumpDest LoopExit = getJumpDestInCurrentScope("upc_forall.end");

  RunCleanupsScope ForScope(*this);

  llvm::Value *Depth = 0;
  if (S.getAfnty()) {
    llvm::Value *DepthAddr = getUPCForAllDepth(CGM);
    Depth = Builder.CreateLoad(DepthAddr);
    Builder.CreateStore(Builder.CreateNUWAdd(Depth,
                                             llvm::ConstantInt::get(IntTy, 1),
                                             "upc_forall.inc_depth"),
                        DepthAddr);
    EHStack.pushCleanup<UPCForAllCleanup>(NormalAndEHCleanup, Depth);
  }

  CGDebugInfo *DI = getDebugInfo();
  if (DI)
    DI->EmitLexicalBlockStart(Builder, S.getSourceRange().getBegin());

  // Evaluate the first part before the loop.
  if (S.getInit())
    EmitStmt(S.getInit());

  // Start the loop with a block that tests the condition.
  // If there's an increment, the continue scope will be overwritten
  // later.
  JumpDest Continue = getJumpDestInCurrentScope("upc_forall.cond");
  llvm::BasicBlock *CondBlock = Continue.getBlock();
  EmitBlock(CondBlock);

  // Create a cleanup scope for the condition variable cleanups.
  RunCleanupsScope ConditionScope(*this);
  
  llvm::Value *BoolCondVal = 0;
  if (S.getCond()) {
    // If the for statement has a condition scope, emit the local variable
    // declaration.
    llvm::BasicBlock *ExitBlock = LoopExit.getBlock();
    if (S.getConditionVariable()) {
      EmitAutoVarDecl(*S.getConditionVariable());
    }

    // If there are any cleanups between here and the loop-exit scope,
    // create a block to stage a loop exit along.
    if (ForScope.requiresCleanups())
      ExitBlock = createBasicBlock("upcforall.cond.cleanup");
    
    // As long as the condition is true, iterate the loop.
    llvm::BasicBlock *ForBody = createBasicBlock("upc_forall.filter");

    // C99 6.8.5p2/p4: The first substatement is executed if the expression
    // compares unequal to 0.  The condition must be a scalar type.
    BoolCondVal = EvaluateExprAsBool(S.getCond());
    Builder.CreateCondBr(BoolCondVal, ForBody, ExitBlock);

    if (ExitBlock != LoopExit.getBlock()) {
      EmitBlock(ExitBlock);
      EmitBranchThroughCleanup(LoopExit);
    }

    EmitBlock(ForBody);
  } else {
    // Treat it as a non-zero constant.  Don't even create a new block for the
    // body, just fall into it.
  }

  // If the for loop doesn't have an increment we can just use the
  // condition as the continue block.  Otherwise we'll need to create
  // a block for it (in the current scope, i.e. in the scope of the
  // condition), and that we will become our continue block.
  if (S.getInc())
    Continue = getJumpDestInCurrentScope("upc_forall.inc");

  // Store the blocks to use for break and continue.
  BreakContinueStack.push_back(BreakContinue(LoopExit, Continue));

  if (const Expr *Afnty = S.getAfnty()) {
    llvm::Value *Affinity = EmitScalarExpr(Afnty);
    if (Afnty->getType()->hasPointerToSharedRepresentation()) {
      // get threadof
      Affinity = EmitUPCPointerGetThread(Affinity);
    } else {
      assert(Affinity->getType()->isIntegerTy());
    }

    llvm::Value *MyThread = EmitUPCMyThread();

    // Make sure that the number of bits match
    unsigned MyThreadBits = cast<llvm::IntegerType>(MyThread->getType())->getBitWidth();
    unsigned AffinityBits = cast<llvm::IntegerType>(Affinity->getType())->getBitWidth();
    if (MyThreadBits != AffinityBits) {
      if (MyThreadBits < AffinityBits) {
        MyThread = Builder.CreateZExt(MyThread, Affinity->getType());
      } else {
        Affinity = Builder.CreateZExt(Affinity, MyThread->getType());
      }
    }

    llvm::Value *Test =
      Builder.CreateOr(Builder.CreateICmpUGT(Depth, llvm::ConstantInt::get(IntTy, 0)),
                        Builder.CreateICmpEQ(Affinity, MyThread));

    llvm::BasicBlock *RealBody = createBasicBlock("upc_forall.body");
    Builder.CreateCondBr(Test, RealBody, Continue.getBlock());
    EmitBlock(RealBody);
  }

  {
    // Create a separate cleanup scope for the body, in case it is not
    // a compound statement.
    RunCleanupsScope BodyScope(*this);
    EmitStmt(S.getBody());
  }

  // If there is an increment, emit it next.
  if (S.getInc()) {
    EmitBlock(Continue.getBlock());
    EmitStmt(S.getInc());
  }

  BreakContinueStack.pop_back();

  ConditionScope.ForceCleanup();
  EmitBranch(CondBlock);

  ForScope.ForceCleanup();

  if (DI)
    DI->EmitLexicalBlockEnd(Builder, S.getSourceRange().getEnd());

  // Emit the fall-through block.
  EmitBlock(LoopExit.getBlock(), true);
}
