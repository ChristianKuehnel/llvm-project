; RUN: llc -O2 -mtriple powerpc-ibm-aix-xcoff -stop-after=machine-cp -mattri=-altivec -verify-machineinstrs < %s | \
; RUN: FileCheck --check-prefixes=CHECK,32BIT %s

; RUN: llc -O2 -verify-machineinstrs -mcpu=pwr4 -mattr=-altivec \
; RUN:  -mtriple powerpc-ibm-aix-xcoff < %s | \
; RUN: FileCheck --check-prefixes=CHECKASM,ASM32PWR4 %s

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind
declare void @llvm.va_start(i8*) #2

; Function Attrs: nounwind
declare void @llvm.va_end(i8*) #2
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

@a = local_unnamed_addr global i32 1, align 4
@b = local_unnamed_addr global i32 2, align 4
@c = local_unnamed_addr global i32 3, align 4
@d = local_unnamed_addr global i32 4, align 4
@e = local_unnamed_addr global i32 5, align 4
@f = local_unnamed_addr global i32 6, align 4
@g = local_unnamed_addr global i32 7, align 4
@h = local_unnamed_addr global i32 8, align 4
@i = local_unnamed_addr global i32 9, align 4
@j = local_unnamed_addr global i32 10, align 4

; Function Attrs: nounwind
define i32 @va_arg1(i32 %a, ...) local_unnamed_addr #0 {
entry:
  %arg = alloca i8*, align 4
  %0 = bitcast i8** %arg to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #2
  call void @llvm.va_start(i8* nonnull %0)
  %cmp7 = icmp sgt i32 %a, 0
  br i1 %cmp7, label %for.body.preheader, label %for.end

for.body.preheader:                               ; preds = %entry
  %argp.cur.pre = load i8*, i8** %arg, align 4
  %min.iters.check = icmp eq i32 %a, 1
  br i1 %min.iters.check, label %for.body.preheader15, label %vector.memcheck

vector.memcheck:                                  ; preds = %for.body.preheader
  %uglygep = getelementptr inbounds i8, i8* %0, i32 1
  %1 = shl i32 %a, 2
  %scevgep = getelementptr i8, i8* %argp.cur.pre, i32 %1
  %bound0 = icmp ugt i8* %scevgep, %0
  %bound1 = icmp ult i8* %argp.cur.pre, %uglygep
  %found.conflict = and i1 %bound0, %bound1
  br i1 %found.conflict, label %for.body.preheader15, label %vector.ph

vector.ph:                                        ; preds = %vector.memcheck
  %n.vec = and i32 %a, -2
  %2 = shl i32 %n.vec, 2
  %ind.end = getelementptr i8, i8* %argp.cur.pre, i32 %2
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi i32 [ undef, %vector.ph ], [ %11, %vector.body ]
  %vec.phi13 = phi i32 [ 0, %vector.ph ], [ %12, %vector.body ]
  %3 = shl i32 %index, 2
  %next.gep = getelementptr i8, i8* %argp.cur.pre, i32 %3
  %4 = shl i32 %index, 2
  %5 = or i32 %4, 4
  %next.gep12 = getelementptr i8, i8* %argp.cur.pre, i32 %5
  %6 = getelementptr inbounds i8, i8* %next.gep12, i32 4
  %7 = bitcast i8* %next.gep to i32*
  %8 = bitcast i8* %next.gep12 to i32*
  %9 = load i32, i32* %7, align 4
  %10 = load i32, i32* %8, align 4
  %11 = add i32 %9, %vec.phi
  %12 = add i32 %10, %vec.phi13
  %index.next = add i32 %index, 2
  %13 = icmp eq i32 %index.next, %n.vec
  br i1 %13, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  store i8* %6, i8** %arg, align 4
  %bin.rdx = add i32 %12, %11
  %cmp.n = icmp eq i32 %n.vec, %a
  br i1 %cmp.n, label %for.end, label %for.body.preheader15

for.body.preheader15:                             ; preds = %middle.block, %vector.memcheck, %for.body.preheader
  %argp.cur.ph = phi i8* [ %argp.cur.pre, %vector.memcheck ], [ %argp.cur.pre, %for.body.preheader ], [ %ind.end, %middle.block ]
  %total.09.ph = phi i32 [ undef, %vector.memcheck ], [ undef, %for.body.preheader ], [ %bin.rdx, %middle.block ]
  %i.08.ph = phi i32 [ 0, %vector.memcheck ], [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  br label %for.body

for.body:                                         ; preds = %for.body.preheader15, %for.body
  %argp.cur = phi i8* [ %argp.next, %for.body ], [ %argp.cur.ph, %for.body.preheader15 ]
  %total.09 = phi i32 [ %add, %for.body ], [ %total.09.ph, %for.body.preheader15 ]
  %i.08 = phi i32 [ %inc, %for.body ], [ %i.08.ph, %for.body.preheader15 ]
  %argp.next = getelementptr inbounds i8, i8* %argp.cur, i32 4
  store i8* %argp.next, i8** %arg, align 4
  %14 = bitcast i8* %argp.cur to i32*
  %15 = load i32, i32* %14, align 4
  %add = add nsw i32 %15, %total.09
  %inc = add nuw nsw i32 %i.08, 1
  %exitcond = icmp eq i32 %inc, %a
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body, %middle.block, %entry
  %total.0.lcssa = phi i32 [ undef, %entry ], [ %bin.rdx, %middle.block ], [ %add, %for.body ]
  call void @llvm.va_end(i8* nonnull %0)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #2
  ret i32 %total.0.lcssa
}


; 32BIT-LABEL:   name:            va_arg1
; 32BIT-LABEL:   liveins:
; 32BIT-DAG:      - { reg: '$r3', virtual-reg: '' }
; 32BIT-DAG:      - { reg: '$r4', virtual-reg: '' }
; 32BIT-DAG:      - { reg: '$r5', virtual-reg: '' }
; 32BIT-DAG:      - { reg: '$r6', virtual-reg: '' }
; 32BIT-DAG:      - { reg: '$r7', virtual-reg: '' }
; 32BIT-DAG:      - { reg: '$r8', virtual-reg: '' }
; 32BIT-DAG:      - { reg: '$r9', virtual-reg: '' }
; 32BIT-DAG:      - { reg: '$r10', virtual-reg: '' }
; 32BIT-LABEL:   fixedStack:
; 32BIT-DAG:      - { id: 0, type: default, offset: 28, size: 4
; 32BIT-LABEL:    body:             |
; 32BIT-LABEL:     bb.0.entry:
; 32BIT-DAG:        liveins: $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10
; 32BIT-DAG:        renamable $cr0 = CMPWI renamable $r3, 1
; 32BIT-DAG:        STW killed renamable $r4, 0, %fixed-stack.0 :: (store 4 into %fixed-stack.0)
; 32BIT-DAG:        STW killed renamable $r5, 4, %fixed-stack.0 :: (store 4 into %fixed-stack.0 + 4)
; 32BIT-DAG:        STW killed renamable $r6, 8, %fixed-stack.0 :: (store 4)
; 32BIT-DAG:        STW killed renamable $r7, 12, %fixed-stack.0 :: (store 4)
; 32BIT-DAG:        STW killed renamable $r8, 16, %fixed-stack.0 :: (store 4)
; 32BIT-DAG:        STW killed renamable $r9, 20, %fixed-stack.0 :: (store 4)
; 32BIT-DAG:        STW killed renamable $r10, 24, %fixed-stack.0 :: (store 4)
; 32BIT-DAG:        renamable $r[[SCRATHREG:[0-9]+]] = ADDI %fixed-stack.0, 0
; 32BIT-DAG:        STW killed renamable $r[[SCRATHREG:[0-9]+]], 0, %stack.0.arg :: (store 4 into %ir.0)

; ASM32PWR4-LABEL:     .va_arg1:
; ASM32PWR4-DAG:       cmpwi	3, 1
; ASM32PWR4-DAG:       stw 4, 28(1)
; ASM32PWR4-DAG:       stw 5, 32(1)
; ASM32PWR4-DAG:       stw 6, 36(1)
; ASM32PWR4-DAG:       stw 7, 40(1)
; ASM32PWR4-DAG:       stw 8, 44(1)
; ASM32PWR4-DAG:       stw 9, 48(1)
; ASM32PWR4-DAG:       stw 10, 52(1)
; ASM32PWR4-DAG:       stw [[SCRATCHREG:[0-9]+]], -4(1)
; ASM32PWR4-DAG:       addi [[SCRATCHREG:[0-9]+]], 1, 28
; ASM32PWR4-DAG:       blt	0, LBB0_8


define i32 @va_arg2(i32 %one, i32 %two, i32 %three, i32 %four, i32 %five, i32 %six, i32 %seven, i32 %eight, ...) local_unnamed_addr #0 {
entry:
  %arg = alloca i8*, align 4
  %0 = bitcast i8** %arg to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %0) #2
  call void @llvm.va_start(i8* nonnull %0)
  %add = add nsw i32 %two, %one
  %add2 = add nsw i32 %add, %three
  %add3 = add nsw i32 %add2, %four
  %add4 = add nsw i32 %add3, %five
  %add5 = add nsw i32 %add4, %six
  %add6 = add nsw i32 %add5, %seven
  %add7 = add nsw i32 %add6, %eight
  %cmp15 = icmp sgt i32 %eight, 0
  br i1 %cmp15, label %for.body.preheader, label %for.end

for.body.preheader:                               ; preds = %entry
  %argp.cur.pre = load i8*, i8** %arg, align 4
  %min.iters.check = icmp eq i32 %eight, 1
  br i1 %min.iters.check, label %for.body.preheader23, label %vector.memcheck

vector.memcheck:                                  ; preds = %for.body.preheader
  %uglygep = getelementptr inbounds i8, i8* %0, i32 1
  %1 = shl i32 %eight, 2
  %scevgep = getelementptr i8, i8* %argp.cur.pre, i32 %1
  %bound0 = icmp ugt i8* %scevgep, %0
  %bound1 = icmp ult i8* %argp.cur.pre, %uglygep
  %found.conflict = and i1 %bound0, %bound1
  br i1 %found.conflict, label %for.body.preheader23, label %vector.ph

vector.ph:                                        ; preds = %vector.memcheck
  %n.vec = and i32 %eight, -2
  %2 = shl i32 %n.vec, 2
  %ind.end = getelementptr i8, i8* %argp.cur.pre, i32 %2
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi i32 [ %add7, %vector.ph ], [ %11, %vector.body ]
  %vec.phi21 = phi i32 [ 0, %vector.ph ], [ %12, %vector.body ]
  %3 = shl i32 %index, 2
  %next.gep = getelementptr i8, i8* %argp.cur.pre, i32 %3
  %4 = shl i32 %index, 2
  %5 = or i32 %4, 4
  %next.gep20 = getelementptr i8, i8* %argp.cur.pre, i32 %5
  %6 = getelementptr inbounds i8, i8* %next.gep20, i32 4
  %7 = bitcast i8* %next.gep to i32*
  %8 = bitcast i8* %next.gep20 to i32*
  %9 = load i32, i32* %7, align 4
  %10 = load i32, i32* %8, align 4
  %11 = add i32 %9, %vec.phi
  %12 = add i32 %10, %vec.phi21
  %index.next = add i32 %index, 2
  %13 = icmp eq i32 %index.next, %n.vec
  br i1 %13, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  store i8* %6, i8** %arg, align 4
  %bin.rdx = add i32 %12, %11
  %cmp.n = icmp eq i32 %n.vec, %eight
  br i1 %cmp.n, label %for.end, label %for.body.preheader23

for.body.preheader23:                             ; preds = %middle.block, %vector.memcheck, %for.body.preheader
  %argp.cur.ph = phi i8* [ %argp.cur.pre, %vector.memcheck ], [ %argp.cur.pre, %for.body.preheader ], [ %ind.end, %middle.block ]
  %total.017.ph = phi i32 [ %add7, %vector.memcheck ], [ %add7, %for.body.preheader ], [ %bin.rdx, %middle.block ]
  %i.016.ph = phi i32 [ 0, %vector.memcheck ], [ 0, %for.body.preheader ], [ %n.vec, %middle.block ]
  br label %for.body

for.body:                                         ; preds = %for.body.preheader23, %for.body
  %argp.cur = phi i8* [ %argp.next, %for.body ], [ %argp.cur.ph, %for.body.preheader23 ]
  %total.017 = phi i32 [ %add8, %for.body ], [ %total.017.ph, %for.body.preheader23 ]
  %i.016 = phi i32 [ %inc, %for.body ], [ %i.016.ph, %for.body.preheader23 ]
  %argp.next = getelementptr inbounds i8, i8* %argp.cur, i32 4
  store i8* %argp.next, i8** %arg, align 4
  %14 = bitcast i8* %argp.cur to i32*
  %15 = load i32, i32* %14, align 4
  %add8 = add nsw i32 %15, %total.017
  %inc = add nuw nsw i32 %i.016, 1
  %exitcond = icmp eq i32 %inc, %eight
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body, %middle.block, %entry
  %total.0.lcssa = phi i32 [ %add7, %entry ], [ %bin.rdx, %middle.block ], [ %add8, %for.body ]
  call void @llvm.va_end(i8* nonnull %0)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %0) #2
  ret i32 %total.0.lcssa
}

; 32BIT-LABEL:   name:            va_arg2
; 32BIT-LABEL:   liveins:
; 32BIT-DAG:     - { reg: '$r3', virtual-reg: '' }
; 32BIT-DAG:     - { reg: '$r4', virtual-reg: '' }
; 32BIT-DAG:     - { reg: '$r5', virtual-reg: '' }
; 32BIT-DAG:     - { reg: '$r6', virtual-reg: '' }
; 32BIT-DAG:     - { reg: '$r7', virtual-reg: '' }
; 32BIT-DAG:     - { reg: '$r8', virtual-reg: '' }
; 32BIT-DAG:     - { reg: '$r9', virtual-reg: '' }
; 32BIT-DAG:     - { reg: '$r10', virtual-reg: '' }
; 32BIT-LABEL:   fixedStack:
; 32BIT-DAG:     - { id: 0, type: default, offset: 56, size: 4
; 32BIT-LABEL:   body:             |
; 32BIT-LABEL:     bb.0.entry:
; 32BIT-DAG:       liveins: $r3, $r4, $r5, $r6, $r7, $r8, $r9, $r10
; 32BIT-DAG:       STW killed renamable $r11, 0, %stack.0.arg :: (store 4 into %ir.0)
; 32BIT-DAG:       renamable $r3 = nsw ADD4 killed renamable $r4, killed renamable $r3
; 32BIT-DAG:       renamable $r3 = nsw ADD4 killed renamable $r3, killed renamable $r5
; 32BIT-DAG:       renamable $r3 = nsw ADD4 killed renamable $r3, killed renamable $r6
; 32BIT-DAG:       renamable $r3 = nsw ADD4 killed renamable $r3, killed renamable $r7
; 32BIT-DAG:       renamable $r3 = nsw ADD4 killed renamable $r3, killed renamable $r8
; 32BIT-DAG:       renamable $r3 = nsw ADD4 killed renamable $r3, killed renamable $r9
; 32BIT-DAG:       renamable $cr0 = CMPWI renamable $r10, 1
; 32BIT-DAG:       renamable $r3 = nsw ADD4 killed renamable $r3, renamable $r10
; 32BIT-DAG:       renamable $r11 = ADDI %fixed-stack.0, 0

; ASM32PWR4-LABEL: .va_arg2:
; ASM32PWR4-DAG:   add 3, 4, 3
; ASM32PWR4-DAG:   add 3, 3, 5
; ASM32PWR4-DAG:   add 3, 3, 6
; ASM32PWR4-DAG:   add 3, 3, 7
; ASM32PWR4-DAG:   add 3, 3, 8
; ASM32PWR4-DAG:   add 3, 3, 9
; ASM32PWR4-DAG:   add 3, 3, 10
; ASM32PWR4-DAG:   cmpwi 10, 1
; ASM32PWR4-DAG:   addi [[SCRATCHREG:[0-9]+]], 1, 56
; ASM32PWR4-DAG:   stw [[SCRATCHREG:[0-9]+]], -4(1)
