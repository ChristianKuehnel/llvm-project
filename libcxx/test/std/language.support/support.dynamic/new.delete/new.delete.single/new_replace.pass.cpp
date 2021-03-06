//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// test operator new replacement

// UNSUPPORTED: sanitizer-new-delete

#include <new>
#include <cstddef>
#include <cstdlib>
#include <cassert>
#include <limits>

#include "count_new.h"
#include "test_macros.h"

bool A_constructed = false;

struct A
{
    A() {A_constructed = true;}
    ~A() {A_constructed = false;}
};

int main(int, char**)
{
    globalMemCounter.reset();
    assert(globalMemCounter.checkOutstandingNewEq(0));
    A *ap = new A;
    DoNotOptimize(ap);
    assert(ap);
    assert(A_constructed);
    assert(globalMemCounter.checkOutstandingNewEq(1));
    delete ap;
    DoNotOptimize(ap);
    assert(!A_constructed);
    assert(globalMemCounter.checkOutstandingNewEq(0));

  return 0;
}
