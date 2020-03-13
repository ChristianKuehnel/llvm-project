// REQUIRES: powerpc-registered-target
// REQUIRES: asserts
// RUN: %clang_cc1 -triple powerpc-ibm-aix-xcoff -emit-llvm -o - %s | FileCheck %s --check-prefix=32BIT
// RUN: %clang_cc1 -triple powerpc64-ibm-aix-xcoff -emit-llvm -o - %s | FileCheck %s --check-prefix=64BIT
#include <stdarg.h>

void aix_varg(int a, ...) {
  va_list arg;
  va_start(arg, a);
  va_arg(arg, int);
  va_end(arg);
}

// 32BIT:           define void @aix_varg(i32 %a, ...) #0 {
// 32BIT:           entry:
// 32BIT-NEXT:        %a.addr = alloca i32, align 4
// 32BIT-NEXT:        %arg = alloca i8*, align 4
// 32BIT-NEXT:        store i32 %a, i32* %a.addr, align 4
// 32BIT-NEXT:        %arg1 = bitcast i8** %arg to i8*
// 32BIT-NEXT:        call void @llvm.va_start(i8* %arg1)
// 32BIT-NEXT:        %argp.cur = load i8*, i8** %arg, align 4
// 32BIT-NEXT:        %argp.next = getelementptr inbounds i8, i8* %argp.cur, i32 4
// 32BIT-NEXT:        store i8* %argp.next, i8** %arg, align 4
// 32BIT-NEXT:        %0 = bitcast i8* %argp.cur to i32*
// 32BIT-NEXT:        %1 = load i32, i32* %0, align 4
// 32BIT-NEXT:        %arg2 = bitcast i8** %arg to i8*
// 32BIT-NEXT:        call void @llvm.va_end(i8* %arg2)
// 32BIT-NEXT:        ret void
// 32BIT-NEXT:      }
// 32BIT:            declare void @llvm.va_start(i8*)
// 32BIT:            declare void @llvm.va_end(i8*)

// 64BIT:           define void @aix_varg(i32 signext %a, ...) #0 {
// 64BIT:           entry:
// 64BIT-NEXT:       %a.addr = alloca i32, align 4
// 64BIT-NEXT:       %arg = alloca i8*, align 8
// 64BIT-NEXT:       store i32 %a, i32* %a.addr, align 4
// 64BIT-NEXT:       %arg1 = bitcast i8** %arg to i8*
// 64BIT-NEXT:       call void @llvm.va_start(i8* %arg1)
// 64BIT-NEXT:       %argp.cur = load i8*, i8** %arg, align 8
// 64BIT-NEXT:       %argp.next = getelementptr inbounds i8, i8* %argp.cur, i64 8
// 64BIT-NEXT:       store i8* %argp.next, i8** %arg, align 8
// 64BIT-NEXT:       %0 = getelementptr inbounds i8, i8* %argp.cur, i64 4
// 64BIT-NEXT:       %1 = bitcast i8* %0 to i32*
// 64BIT-NEXT:       %2 = load i32, i32* %1, align 4
// 64BIT-NEXT:       %arg2 = bitcast i8** %arg to i8*
// 64BIT-NEXT:       call void @llvm.va_end(i8* %arg2)
// 64BIT-NEXT:       ret void
// 64BIT-NEXT:     }
// 64BIT:          declare void @llvm.va_start(i8*)
// 64BIT:          declare void @llvm.va_end(i8*)
