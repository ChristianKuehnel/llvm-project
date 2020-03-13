// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fcoroutines-ts -std=c++1z -emit-llvm %s -o - -disable-llvm-passes | FileCheck %s

namespace std {
template <typename a> struct b { b(int, a); };
template <typename c> struct d { c *operator->(); };
template <typename, typename = int> struct e {};
} // namespace std
enum f {};
namespace std {
namespace experimental {
template <typename g> struct coroutine_traits : g {};
template <typename = void> struct coroutine_handle;
template <> struct coroutine_handle<> {};
template <typename> struct coroutine_handle : coroutine_handle<> {
  static coroutine_handle from_address(void *);
};
struct h {
  int await_ready();
  void await_suspend(coroutine_handle<>);
  void await_resume();
};
} // namespace experimental
} // namespace std
template <typename = void> using i = std::experimental::coroutine_handle<>;
template <typename ag> auto ah(ag) { return ag().ah(0); }
template <typename> struct k;
struct l {
  struct m {
    int await_ready();
    template <typename al>
    void await_suspend(std::experimental::coroutine_handle<al>);
    void await_resume();
  };
  std::experimental::h initial_suspend();
  m final_suspend();
  template <typename ag> auto await_transform(ag) { return ah(ag()); }
};
template <typename am> struct n : l {
  k<am> get_return_object();
  void return_value(am);
  void unhandled_exception();
};
struct o {
  using ap = i<>;
  o(ap);
  int await_ready();
};
template <typename am> struct k {
  using promise_type = n<am>;
  using ap = i<>;
  ap ar;
  struct p : o {
    using at = o;
    p(ap q) : at(q) {}
    void await_suspend(std::experimental::coroutine_handle<>);
  };
  struct r : p {
    r(ap q) : p(q) {}
    am await_resume();
  };
  auto ah(int) { return r(ar); }
};
template <typename am, typename av, typename aw>
auto ax(std::e<k<am>, av>, aw) -> k<std::e<int, aw>>;
struct s {
  s(int);
};
struct K;
f j;
struct t {
  std::d<int> bh();
  std::d<K> bi;
};
template <typename> struct M {
  using bm = int;
  static k<int> bh();
  static k<std::b<std::e<bm, s>>> bo();
};
template <typename bc> k<int> M<bc>::bh() { bo; }

// CHECK-LABEL: _ZN1MIiE2boEv(
template <typename bc> k<std::b<std::e<int, s>>> M<bc>::bo() {
  std::e<k<int>> bu;
  s bw(0);
// CHECK: _ZN1nISt1bISt1eIi1sEEE12return_valueES4_(%struct.n* %__promise)
  co_return{0, co_await ax(bu, bw)};
}
template <typename> struct u {
  template <typename av>
  k<int> by(int *, unsigned long, std::e<unsigned long, av>, unsigned long, f,
            int *, int *);
};
template <typename bc>
template <typename av>
k<int> u<bc>::by(int *, unsigned long, std::e<unsigned long, av>, unsigned long,
                 f, int *, int *) {
  M<bc>::bh;
}
struct K {
  template <typename av>
  k<int> by(unsigned long, std::e<unsigned long, av>, unsigned long, f, int *,
            int *);
  template <typename av>
  k<int> by(unsigned long, const std::e<int, av> &, unsigned long, f, int *,
            int *);
};
template <typename av>
k<int> K::by(unsigned long, const std::e<int, av> &, unsigned long, f p4, int *,
             int *) {
  std::e<unsigned long> cj;
  by(0, cj, 0, p4, 0, 0);
}
template <typename av>
k<int> K::by(unsigned long, std::e<unsigned long, av> v, unsigned long, f p4,
             int *, int *) {
  static_cast<u<int> *>(0)->by(0, 0, v, 0, p4, 0, 0);
}
using namespace std;
d<int> t::bh() {
  e<int> cm;
  auto cn = [&] { bi->by(0, cm, 0, j, 0, 0); };
  cn();
}
