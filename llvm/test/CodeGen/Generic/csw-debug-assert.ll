; REQUIRES: asserts
; RUN: llc -O1 -regalloc=pbqp %s -o %t.o

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local void @test(i16* noalias %a, i16* noalias %b, i16* noalias %c, i32 %n) local_unnamed_addr #0 !dbg !7 {
entry:
  call void @llvm.dbg.value(metadata i16* %a, metadata !22, metadata !DIExpression()), !dbg !30
  call void @llvm.dbg.value(metadata i16* %b, metadata !23, metadata !DIExpression()), !dbg !30
  call void @llvm.dbg.value(metadata i16* %c, metadata !24, metadata !DIExpression()), !dbg !30
  call void @llvm.dbg.value(metadata i32 %n, metadata !25, metadata !DIExpression()), !dbg !30
  call void @llvm.dbg.value(metadata i32 0, metadata !26, metadata !DIExpression()), !dbg !31
  br label %for.cond, !dbg !32

for.cond:                                         ; preds = %for.body, %entry
  %b.addr.0 = phi i16* [ %b, %entry ], [ %incdec.ptr1, %for.body ]
  %c.addr.0 = phi i16* [ %c, %entry ], [ %incdec.ptr4, %for.body ]
  %a.addr.0 = phi i16* [ %a, %entry ], [ %incdec.ptr, %for.body ]
  %i.0 = phi i32 [ 0, %entry ], [ %inc, %for.body ], !dbg !31
  call void @llvm.dbg.value(metadata i32 %i.0, metadata !26, metadata !DIExpression()), !dbg !31
  call void @llvm.dbg.value(metadata i16* %a.addr.0, metadata !22, metadata !DIExpression()), !dbg !30
  call void @llvm.dbg.value(metadata i16* %c.addr.0, metadata !24, metadata !DIExpression()), !dbg !30
  call void @llvm.dbg.value(metadata i16* %b.addr.0, metadata !23, metadata !DIExpression()), !dbg !30
  %cmp = icmp ult i32 %i.0, %n, !dbg !33
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !35

for.cond.cleanup:                                 ; preds = %for.cond
  ret void, !dbg !36

for.body:                                         ; preds = %for.cond
  %incdec.ptr = getelementptr inbounds i16, i16* %a.addr.0, i32 1, !dbg !37
  call void @llvm.dbg.value(metadata i16* %incdec.ptr, metadata !22, metadata !DIExpression()), !dbg !30
  %0 = load i16, i16* %a.addr.0, align 2, !dbg !39, !tbaa !40
  %conv = sext i16 %0 to i32, !dbg !39
  %incdec.ptr1 = getelementptr inbounds i16, i16* %b.addr.0, i32 1, !dbg !44
  call void @llvm.dbg.value(metadata i16* %incdec.ptr1, metadata !23, metadata !DIExpression()), !dbg !30
  %1 = load i16, i16* %b.addr.0, align 2, !dbg !45, !tbaa !40
  %conv2 = sext i16 %1 to i32, !dbg !45
  %add = add nsw i32 %conv, %conv2, !dbg !46
  %conv3 = trunc i32 %add to i16, !dbg !39
  %incdec.ptr4 = getelementptr inbounds i16, i16* %c.addr.0, i32 1, !dbg !47
  call void @llvm.dbg.value(metadata i16* %incdec.ptr4, metadata !24, metadata !DIExpression()), !dbg !30
  store i16 %conv3, i16* %c.addr.0, align 2, !dbg !48, !tbaa !40
  %inc = add nsw i32 %i.0, 1, !dbg !49
  call void @llvm.dbg.value(metadata i32 %inc, metadata !26, metadata !DIExpression()), !dbg !31
  br label %for.cond, !dbg !50, !llvm.loop !51
}

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { nounwind uwtable optnone noinline "correctly-rounded-divide-sqrt-fp-math"="false" "denormal-fp-math"="ieee,ieee" "denormal-fp-math-f32"="ieee,ieee" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 11.0.0 (https://github.com/llvm/llvm-project.git afaeb817468d2fdc0a315a7ff136db245e59a8eb)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "csw-debug-assert.c", directory: "dir")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 11.0.0 (https://github.com/llvm/llvm-project.git afaeb817468d2fdc0a315a7ff136db245e59a8eb)"}
!7 = distinct !DISubprogram(name: "test", scope: !8, file: !8, line: 6, type: !9, scopeLine: 6, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !21)
!8 = !DIFile(filename: "csw-debug-assert.c", directory: "dir")
!9 = !DISubroutineType(types: !10)
!10 = !{null, !11, !11, !17, !19}
!11 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !12)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!13 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !14)
!14 = !DIDerivedType(tag: DW_TAG_typedef, name: "int16_t", file: !15, line: 37, baseType: !16)
!15 = !DIFile(filename: "/usr/include/stdint.h", directory: "")
!16 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!17 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !18)
!18 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !14, size: 64)
!19 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint32_t", file: !15, line: 51, baseType: !20)
!20 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!21 = !{!22, !23, !24, !25, !26}
!22 = !DILocalVariable(name: "a", arg: 1, scope: !7, file: !8, line: 6, type: !11)
!23 = !DILocalVariable(name: "b", arg: 2, scope: !7, file: !8, line: 6, type: !11)
!24 = !DILocalVariable(name: "c", arg: 3, scope: !7, file: !8, line: 6, type: !17)
!25 = !DILocalVariable(name: "n", arg: 4, scope: !7, file: !8, line: 6, type: !19)
!26 = !DILocalVariable(name: "i", scope: !27, file: !8, line: 7, type: !28)
!27 = distinct !DILexicalBlock(scope: !7, file: !8, line: 7, column: 5)
!28 = !DIDerivedType(tag: DW_TAG_typedef, name: "int32_t", file: !15, line: 38, baseType: !29)
!29 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!30 = !DILocation(line: 0, scope: !7)
!31 = !DILocation(line: 0, scope: !27)
!32 = !DILocation(line: 7, column: 10, scope: !27)
!33 = !DILocation(line: 7, column: 27, scope: !34)
!34 = distinct !DILexicalBlock(scope: !27, file: !8, line: 7, column: 5)
!35 = !DILocation(line: 7, column: 5, scope: !27)
!36 = !DILocation(line: 10, column: 1, scope: !7)
!37 = !DILocation(line: 8, column: 18, scope: !38)
!38 = distinct !DILexicalBlock(scope: !34, file: !8, line: 7, column: 37)
!39 = !DILocation(line: 8, column: 16, scope: !38)
!40 = !{!41, !41, i64 0}
!41 = !{!"short", !42, i64 0}
!42 = !{!"omnipotent char", !43, i64 0}
!43 = !{!"Simple C/C++ TBAA"}
!44 = !DILocation(line: 8, column: 25, scope: !38)
!45 = !DILocation(line: 8, column: 23, scope: !38)
!46 = !DILocation(line: 8, column: 21, scope: !38)
!47 = !DILocation(line: 8, column: 11, scope: !38)
!48 = !DILocation(line: 8, column: 14, scope: !38)
!49 = !DILocation(line: 7, column: 33, scope: !34)
!50 = !DILocation(line: 7, column: 5, scope: !34)
!51 = distinct !{!51, !35, !52}
!52 = !DILocation(line: 9, column: 5, scope: !27)
