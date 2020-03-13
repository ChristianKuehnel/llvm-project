// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm -fcoroutines-ts \
// RUN:   -fexperimental-new-pass-manager -O0 %s -o - | FileCheck %s
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm -fcoroutines-ts \
// RUN:   -fexperimental-new-pass-manager -fno-inline -O0 %s -o - | FileCheck %s

// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm -fcoroutines-ts \
// RUN:   -O0 %s -o - | FileCheck %s
// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm -fcoroutines-ts \
// RUN:   -fno-inline -O0 %s -o - | FileCheck %s

namespace std {
namespace experimental {

struct handle {};

struct awaitable {
  bool await_ready() { return true; }
  // CHECK-NOT: await_suspend
  inline void __attribute__((__always_inline__)) await_suspend(handle) {}
  bool await_resume() { return true; }
};

template <typename T>
struct coroutine_handle {
  static handle from_address(void *address) { return {}; }
};

template <typename T = void>
struct coroutine_traits {
  struct promise_type {
    awaitable initial_suspend() { return {}; }
    awaitable final_suspend() { return {}; }
    void return_void() {}
    T get_return_object() { return T(); }
    void unhandled_exception() {}
  };
};
} // namespace experimental
} // namespace std

// CHECK-LABEL: @_Z3foov.resume
// CHECK: call void @llvm.lifetime.start
// CHECK: call void @llvm.lifetime.end
void foo() { co_return; }
