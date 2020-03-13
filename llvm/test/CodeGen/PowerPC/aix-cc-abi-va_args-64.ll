; RUN: llc -O2 -mtriple powerpc64-ibm-aix-xcoff -stop-after=machine-cp -verify-machineinstrs < %s | \
; RUN: FileCheck --check-prefixes=CHECK,64BIT %s

; RUN: llc -O2 -verify-machineinstrs -mcpu=pwr4 -mattr=-altivec \
; RUN:  -mtriple powerpc64-ibm-aix-xcoff < %s | \
; RUN: FileCheck --check-prefixes=CHECKASM,ASM64PWR4 %s


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

define signext i32 @va_arg1(i32 signext %a, ...) local_unnamed_addr #0 {
entry:
  %arg = alloca i8*, align 8
  %0 = bitcast i8** %arg to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %0) #2
  call void @llvm.va_start(i8* nonnull %0)
  %cmp7 = icmp sgt i32 %a, 0
  br i1 %cmp7, label %for.body.preheader, label %for.end

for.body.preheader:                               ; preds = %entry
  %argp.cur.pre = load i8*, i8** %arg, align 8
  %1 = add i32 %a, -1
  %2 = zext i32 %1 to i64
  %3 = add nuw nsw i64 %2, 1
  %min.iters.check = icmp ult i32 %1, 8
  br i1 %min.iters.check, label %for.body.preheader28, label %vector.memcheck

vector.memcheck:                                  ; preds = %for.body.preheader
  %uglygep = getelementptr inbounds i8, i8* %0, i64 1
  %scevgep = getelementptr i8, i8* %argp.cur.pre, i64 4
  %4 = shl nuw nsw i64 %2, 3
  %5 = add nuw nsw i64 %4, 8
  %scevgep11 = getelementptr i8, i8* %argp.cur.pre, i64 %5
  %bound0 = icmp ugt i8* %scevgep11, %0
  %bound1 = icmp ult i8* %scevgep, %uglygep
  %found.conflict = and i1 %bound0, %bound1
  br i1 %found.conflict, label %for.body.preheader28, label %vector.ph

vector.ph:                                        ; preds = %vector.memcheck
  %n.mod.vf = and i64 %3, 7
  %6 = icmp eq i64 %n.mod.vf, 0
  %7 = select i1 %6, i64 8, i64 %n.mod.vf
  %n.vec = sub nsw i64 %3, %7
  %8 = shl nsw i64 %n.vec, 3
  %ind.end = getelementptr i8, i8* %argp.cur.pre, i64 %8
  %ind.end13 = trunc i64 %n.vec to i32
  %next.gep = getelementptr i8, i8* %argp.cur.pre, i64 4
  %next.gep17 = getelementptr i8, i8* %argp.cur.pre, i64 4
  %next.gep20 = getelementptr i8, i8* %argp.cur.pre, i64 8
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <4 x i32> [ <i32 undef, i32 0, i32 0, i32 0>, %vector.ph ], [ %19, %vector.body ]
  %vec.phi21 = phi <4 x i32> [ zeroinitializer, %vector.ph ], [ %20, %vector.body ]
  %9 = shl i64 %index, 3
  %10 = shl i64 %index, 3
  %11 = or i64 %10, 32
  %12 = shl i64 %index, 3
  %13 = or i64 %12, 56
  %14 = getelementptr inbounds i8, i8* %next.gep20, i64 %13
  %15 = getelementptr inbounds i8, i8* %next.gep, i64 %9
  %16 = getelementptr inbounds i8, i8* %next.gep17, i64 %11
  %17 = bitcast i8* %15 to <8 x i32>*
  %18 = bitcast i8* %16 to <8 x i32>*
  %wide.vec = load <8 x i32>, <8 x i32>* %17, align 4
  %wide.vec23 = load <8 x i32>, <8 x i32>* %18, align 4
  %strided.vec = shufflevector <8 x i32> %wide.vec, <8 x i32> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %strided.vec24 = shufflevector <8 x i32> %wide.vec23, <8 x i32> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %19 = add <4 x i32> %strided.vec, %vec.phi
  %20 = add <4 x i32> %strided.vec24, %vec.phi21
  %index.next = add i64 %index, 8
  %21 = icmp eq i64 %index.next, %n.vec
  br i1 %21, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  store i8* %14, i8** %arg, align 8
  %bin.rdx = add <4 x i32> %20, %19
  %rdx.shuf = shufflevector <4 x i32> %bin.rdx, <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %bin.rdx25 = add <4 x i32> %bin.rdx, %rdx.shuf
  %rdx.shuf26 = shufflevector <4 x i32> %bin.rdx25, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %bin.rdx27 = add <4 x i32> %bin.rdx25, %rdx.shuf26
  %22 = extractelement <4 x i32> %bin.rdx27, i32 0
  br label %for.body.preheader28

for.body.preheader28:                             ; preds = %middle.block, %vector.memcheck, %for.body.preheader
  %argp.cur.ph = phi i8* [ %argp.cur.pre, %vector.memcheck ], [ %argp.cur.pre, %for.body.preheader ], [ %ind.end, %middle.block ]
  %total.09.ph = phi i32 [ undef, %vector.memcheck ], [ undef, %for.body.preheader ], [ %22, %middle.block ]
  %i.08.ph = phi i32 [ 0, %vector.memcheck ], [ 0, %for.body.preheader ], [ %ind.end13, %middle.block ]
  br label %for.body

for.body:                                         ; preds = %for.body.preheader28, %for.body
  %argp.cur = phi i8* [ %argp.next, %for.body ], [ %argp.cur.ph, %for.body.preheader28 ]
  %total.09 = phi i32 [ %add, %for.body ], [ %total.09.ph, %for.body.preheader28 ]
  %i.08 = phi i32 [ %inc, %for.body ], [ %i.08.ph, %for.body.preheader28 ]
  %argp.next = getelementptr inbounds i8, i8* %argp.cur, i64 8
  store i8* %argp.next, i8** %arg, align 8
  %23 = getelementptr inbounds i8, i8* %argp.cur, i64 4
  %24 = bitcast i8* %23 to i32*
  %25 = load i32, i32* %24, align 4
  %add = add nsw i32 %25, %total.09
  %inc = add nuw nsw i32 %i.08, 1
  %exitcond = icmp eq i32 %inc, %a
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body, %entry
  %total.0.lcssa = phi i32 [ undef, %entry ], [ %add, %for.body ]
  call void @llvm.va_end(i8* nonnull %0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %0) #2
  ret i32 %total.0.lcssa
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

; Function Attrs: nounwind
declare void @llvm.va_start(i8*) #2

; Function Attrs: nounwind
declare void @llvm.va_end(i8*) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

; 64BIT-LABEL:   name:            va_arg1
; 64BIT-LABEL:   liveins:
; 64BIT-DAG:      - { reg: '$x3', virtual-reg: '' }
; 64BIT-DAG:      - { reg: '$x4', virtual-reg: '' }
; 64BIT-DAG:      - { reg: '$x5', virtual-reg: '' }
; 64BIT-DAG:      - { reg: '$x6', virtual-reg: '' }
; 64BIT-DAG:      - { reg: '$x7', virtual-reg: '' }
; 64BIT-DAG:      - { reg: '$x8', virtual-reg: '' }
; 64BIT-DAG:      - { reg: '$x9', virtual-reg: '' }
; 64BIT-DAG:      - { reg: '$x10', virtual-reg: '' }
; 64BIT-LABEL:   fixedStack:
; 64BIT-DAG:      - { id: 0, type: default, offset: 56, size: 8
; 64BIT-LABEL:    body:             |
; 64BIT-LABEL:     bb.0.entry:
; 64BIT-DAG:      liveins: $x3, $x4, $x5, $x6, $x7, $x8, $x9, $x10
; 64BIT-DAG:      renamable $cr0 = CMPWI renamable $r3, 1
; 64BIT-DAG:      STD killed renamable $x4, 0, %fixed-stack.0 :: (store 8 into %fixed-stack.0)
; 64BIT-DAG:      STD killed renamable $x5, 8, %fixed-stack.0 :: (store 8 into %fixed-stack.0 + 8)
; 64BIT-DAG:      STD killed renamable $x6, 16, %fixed-stack.0 :: (store 8)
; 64BIT-DAG:      STD killed renamable $x7, 24, %fixed-stack.0 :: (store 8)
; 64BIT-DAG:      STD killed renamable $x8, 32, %fixed-stack.0 :: (store 8)
; 64BIT-DAG:      STD killed renamable $x9, 40, %fixed-stack.0 :: (store 8)
; 64BIT-DAG:      STD killed renamable $x10, 48, %fixed-stack.0 :: (store 8)
; 64BIT-DAG:      renamable $x[[SCRATCHREG:[0-9]+]] = ADDI8 %fixed-stack.0, 0
; 64BIT-DAG:      STD killed renamable $x[[SCRATCHREG:[0-9]+]], 0, %stack.0.arg :: (store 8 into %ir.0)

; ASM64PWR4-LABEL:    .va_arg1:
; ASM64PWR4-DAG:       cmpwi	3, 1
; ASM64PWR4-DAG:       std 4, 56(1)
; ASM64PWR4-DAG:       std 5, 64(1)
; ASM64PWR4-DAG:       std 6, 72(1)
; ASM64PWR4-DAG:       std 7, 80(1)
; ASM64PWR4-DAG:       std 8, 88(1)
; ASM64PWR4-DAG:       std 9, 96(1)
; ASM64PWR4-DAG:       std 10, 104(1)
; ASM64PWR4-DAG:       addi [[SCRATCHREG:[0-9]+]], 1, 56

define signext i32 @va_arg2(i32 signext %one, i32 signext %two, i32 signext %three, i32 signext %four, i32 signext %five, i32 signext %six, i32 signext %seven, i32 signext %eight, ...) local_unnamed_addr #0 {
entry:
  %arg = alloca i8*, align 8
  %0 = bitcast i8** %arg to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %0) #2
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
  %argp.cur.pre = load i8*, i8** %arg, align 8
  %1 = add i32 %eight, -1
  %2 = zext i32 %1 to i64
  %3 = add nuw nsw i64 %2, 1
  %min.iters.check = icmp ult i32 %1, 8
  br i1 %min.iters.check, label %for.body.preheader36, label %vector.memcheck

vector.memcheck:                                  ; preds = %for.body.preheader
  %uglygep = getelementptr inbounds i8, i8* %0, i64 1
  %scevgep = getelementptr i8, i8* %argp.cur.pre, i64 4
  %4 = shl nuw nsw i64 %2, 3
  %5 = add nuw nsw i64 %4, 8
  %scevgep19 = getelementptr i8, i8* %argp.cur.pre, i64 %5
  %bound0 = icmp ugt i8* %scevgep19, %0
  %bound1 = icmp ult i8* %scevgep, %uglygep
  %found.conflict = and i1 %bound0, %bound1
  br i1 %found.conflict, label %for.body.preheader36, label %vector.ph

vector.ph:                                        ; preds = %vector.memcheck
  %n.mod.vf = and i64 %3, 7
  %6 = icmp eq i64 %n.mod.vf, 0
  %7 = select i1 %6, i64 8, i64 %n.mod.vf
  %n.vec = sub nsw i64 %3, %7
  %8 = shl nsw i64 %n.vec, 3
  %ind.end = getelementptr i8, i8* %argp.cur.pre, i64 %8
  %ind.end21 = trunc i64 %n.vec to i32
  %9 = insertelement <4 x i32> <i32 undef, i32 0, i32 0, i32 0>, i32 %add7, i32 0
  %next.gep = getelementptr i8, i8* %argp.cur.pre, i64 4
  %next.gep25 = getelementptr i8, i8* %argp.cur.pre, i64 4
  %next.gep28 = getelementptr i8, i8* %argp.cur.pre, i64 8
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i64 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <4 x i32> [ %9, %vector.ph ], [ %20, %vector.body ]
  %vec.phi29 = phi <4 x i32> [ zeroinitializer, %vector.ph ], [ %21, %vector.body ]
  %10 = shl i64 %index, 3
  %11 = shl i64 %index, 3
  %12 = or i64 %11, 32
  %13 = shl i64 %index, 3
  %14 = or i64 %13, 56
  %15 = getelementptr inbounds i8, i8* %next.gep28, i64 %14
  %16 = getelementptr inbounds i8, i8* %next.gep, i64 %10
  %17 = getelementptr inbounds i8, i8* %next.gep25, i64 %12
  %18 = bitcast i8* %16 to <8 x i32>*
  %19 = bitcast i8* %17 to <8 x i32>*
  %wide.vec = load <8 x i32>, <8 x i32>* %18, align 4
  %wide.vec31 = load <8 x i32>, <8 x i32>* %19, align 4
  %strided.vec = shufflevector <8 x i32> %wide.vec, <8 x i32> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %strided.vec32 = shufflevector <8 x i32> %wide.vec31, <8 x i32> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %20 = add <4 x i32> %strided.vec, %vec.phi
  %21 = add <4 x i32> %strided.vec32, %vec.phi29
  %index.next = add i64 %index, 8
  %22 = icmp eq i64 %index.next, %n.vec
  br i1 %22, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  store i8* %15, i8** %arg, align 8
  %bin.rdx = add <4 x i32> %21, %20
  %rdx.shuf = shufflevector <4 x i32> %bin.rdx, <4 x i32> undef, <4 x i32> <i32 2, i32 3, i32 undef, i32 undef>
  %bin.rdx33 = add <4 x i32> %bin.rdx, %rdx.shuf
  %rdx.shuf34 = shufflevector <4 x i32> %bin.rdx33, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %bin.rdx35 = add <4 x i32> %bin.rdx33, %rdx.shuf34
  %23 = extractelement <4 x i32> %bin.rdx35, i32 0
  br label %for.body.preheader36

for.body.preheader36:                             ; preds = %middle.block, %vector.memcheck, %for.body.preheader
  %argp.cur.ph = phi i8* [ %argp.cur.pre, %vector.memcheck ], [ %argp.cur.pre, %for.body.preheader ], [ %ind.end, %middle.block ]
  %total.017.ph = phi i32 [ %add7, %vector.memcheck ], [ %add7, %for.body.preheader ], [ %23, %middle.block ]
  %i.016.ph = phi i32 [ 0, %vector.memcheck ], [ 0, %for.body.preheader ], [ %ind.end21, %middle.block ]
  br label %for.body

for.body:                                         ; preds = %for.body.preheader36, %for.body
  %argp.cur = phi i8* [ %argp.next, %for.body ], [ %argp.cur.ph, %for.body.preheader36 ]
  %total.017 = phi i32 [ %add8, %for.body ], [ %total.017.ph, %for.body.preheader36 ]
  %i.016 = phi i32 [ %inc, %for.body ], [ %i.016.ph, %for.body.preheader36 ]
  %argp.next = getelementptr inbounds i8, i8* %argp.cur, i64 8
  store i8* %argp.next, i8** %arg, align 8
  %24 = getelementptr inbounds i8, i8* %argp.cur, i64 4
  %25 = bitcast i8* %24 to i32*
  %26 = load i32, i32* %25, align 4
  %add8 = add nsw i32 %26, %total.017
  %inc = add nuw nsw i32 %i.016, 1
  %exitcond = icmp eq i32 %inc, %eight
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.body, %entry
  %total.0.lcssa = phi i32 [ %add7, %entry ], [ %add8, %for.body ]
  call void @llvm.va_end(i8* nonnull %0)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %0) #2
  ret i32 %total.0.lcssa
}

; 64BIT-LABEL:   name:            va_arg2
; 64BIT-LABEL:   liveins:
; 64BIT-DAG:     - { reg: '$x3', virtual-reg: '' }
; 64BIT-DAG:     - { reg: '$x4', virtual-reg: '' }
; 64BIT-DAG:     - { reg: '$x5', virtual-reg: '' }
; 64BIT-DAG:     - { reg: '$x6', virtual-reg: '' }
; 64BIT-DAG:     - { reg: '$x7', virtual-reg: '' }
; 64BIT-DAG:     - { reg: '$x8', virtual-reg: '' }
; 64BIT-DAG:     - { reg: '$x9', virtual-reg: '' }
; 64BIT-DAG:     - { reg: '$x10', virtual-reg: '' }
; 64BIT-LABEL:   fixedStack:
; 64BIT-DAG:     - { id: 0, type: default, offset: 112, size: 8
; 64BIT-LABEL:   body:             |
; 64BIT-LABEL:     bb.0.entry:
; 64BIT-DAG:       liveins: $x3, $x4, $x5, $x6, $x7, $x8, $x9, $x10
; 64BIT-DAG:       renamable $r[[SCRATCHREG:[0-9]+]] = nsw ADD4 renamable $r4, renamable $r3, implicit killed $x3, implicit killed $x4
; 64BIT-DAG:       renamable $r[[SCRATCHREG:[0-9]+]] = nsw ADD4 killed renamable $r[[SCRATCHREG:[0-9]+]], renamable $r5, implicit killed $x5
; 64BIT-DAG:       renamable $r[[SCRATCHREG:[0-9]+]] = nsw ADD4 killed renamable $r[[SCRATCHREG:[0-9]+]], renamable $r6, implicit killed $x6
; 64BIT-DAG:       renamable $r[[SCRATCHREG:[0-9]+]] = nsw ADD4 killed renamable $r[[SCRATCHREG:[0-9]+]], renamable $r7, implicit killed $x7
; 64BIT-DAG:       renamable $r[[SCRATCHREG:[0-9]+]] = nsw ADD4 killed renamable $r[[SCRATCHREG:[0-9]+]], renamable $r8, implicit killed $x8
; 64BIT-DAG:       renamable $r[[SCRATCHREG:[0-9]+]] = nsw ADD4 killed renamable $r[[SCRATCHREG:[0-9]+]], renamable $r9, implicit killed $x9
; 64BIT-DAG:       renamable $cr0 = CMPWI renamable $r10, 1
; 64BIT-DAG:       renamable $r[[SCRATCHREG:[0-9]+]] = nsw ADD4 killed renamable $r[[SCRATCHREG:[0-9]+]], renamable $r10
; 64BIT-DAG:       STD killed renamable $x[[SCRATCHREG:[0-9]+]], 0, %stack.0.arg :: (store 8 into %ir.0)
; 64BIT-DAG:       renamable $x[[SCRATCHREG:[0-9]+]] = ADDI8 %fixed-stack.0, 0

; ASM64PWR4-LABEL: .va_arg2:
; ASM64PWR4-DAG:   add 3, 4, 3
; ASM64PWR4-DAG:   add 3, 3, 5
; ASM64PWR4-DAG:   add 3, 3, 6
; ASM64PWR4-DAG:   add 3, 3, 7
; ASM64PWR4-DAG:   add 3, 3, 8
; ASM64PWR4-DAG:   add 3, 3, 9
; ASM64PWR4-DAG:   add 3, 3, 10
; ASM64PWR4-DAG:   cmpwi 10, 1
; ASM64PWR4-DAG:   addi [[SCRATCHREG:[0-9]+]], 1, 112
