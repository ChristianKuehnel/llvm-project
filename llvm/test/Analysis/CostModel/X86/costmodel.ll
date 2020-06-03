; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py
; RUN: opt < %s -cost-model -cost-kind=latency -analyze -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 | FileCheck %s --check-prefix=LATENCY
; RUN: opt < %s -cost-model -cost-kind=code-size -analyze -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 | FileCheck %s --check-prefix=CODESIZE

; Tests if the interface TargetTransformInfo::getInstructionCost() works correctly.

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"

declare { i32, i1 } @llvm.uadd.with.overflow.i32(i32, i32)

define i64 @foo(i64 %arg) {
; LATENCY-LABEL: 'foo'
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %A1 = alloca i32, align 8
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %A2 = alloca i64, i64 undef, align 8
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %I64 = add i64 undef, undef
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 4 for instruction: %1 = load i64, i64* undef, align 4
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %BC = bitcast i8* undef to i32*
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %I2P = inttoptr i64 undef to i8*
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %P2I = ptrtoint i8* undef to i64
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %TC = trunc i64 undef to i32
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %uadd = call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 undef, i32 undef)
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 40 for instruction: call void undef()
; LATENCY-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 undef
;
; CODESIZE-LABEL: 'foo'
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %A1 = alloca i32, align 8
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %A2 = alloca i64, i64 undef, align 8
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %I64 = add i64 undef, undef
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %1 = load i64, i64* undef, align 4
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %BC = bitcast i8* undef to i32*
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %I2P = inttoptr i64 undef to i8*
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %P2I = ptrtoint i8* undef to i64
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: %TC = trunc i64 undef to i32
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %uadd = call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 undef, i32 undef)
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: call void undef()
; CODESIZE-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: ret i64 undef
;
  %A1 = alloca i32, align 8
  %A2 = alloca i64, i64 undef, align 8
  %I64 = add i64 undef, undef
  load i64, i64* undef, align 4
  %BC = bitcast i8* undef to i32*
  %I2P = inttoptr i64 undef to i8*
  %P2I = ptrtoint i8* undef to i64
  %TC = trunc i64 undef to i32
  %uadd = call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 undef, i32 undef)
  call void undef()
  ret i64 undef
}
