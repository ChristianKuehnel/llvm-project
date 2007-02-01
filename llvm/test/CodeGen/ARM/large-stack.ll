; RUN: llvm-as < %s | llc -march=arm &&
; RUN: llvm-as < %s | llc -march=arm -enable-thumb &&
; RUN: llvm-as < %s | llc -march=arm -enable-thumb | \
; RUN:    grep 'ldr.*LCP' | wc -l | grep 5
; XFAIL: *86-pc-linux-gnu

define void @test1() {
    %tmp = alloca [ 64 x i32 ] , align 4
    ret void
}

define void @test2() {
    %tmp = alloca [ 4168 x i8 ] , align 4
    ret void
}

define i32 @test3() {
	%retval = alloca i32, align 4
	%tmp = alloca i32, align 4
	%a = alloca [805306369 x i8], align 16
	store i32 0, i32* %tmp
	%tmp1 = load i32* %tmp
        ret i32 %tmp1
}
