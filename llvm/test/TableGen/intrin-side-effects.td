// RUN: llvm-tblgen -gen-intrinsic-impl -I %p/../../include %s | FileCheck %s

// Get the minimum blurb necessary to process ...
include "llvm/CodeGen/ValueTypes.td"
include "llvm/CodeGen/SDNodeProperties.td"

class LLVMType<ValueType vt> {
  ValueType VT = vt;
  int isAny = 0;
}

class LLVMQualPointerType<LLVMType elty, int addrspace>
  : LLVMType<iPTR>{
  LLVMType ElTy = elty;
  int AddrSpace = addrspace;
}

class LLVMPointerType<LLVMType elty>
  : LLVMQualPointerType<elty, 0>;

def llvm_i8_ty         : LLVMType<i8>;
def llvm_i32_ty        : LLVMType<i32>;
def llvm_ptr_ty        : LLVMPointerType<llvm_i8_ty>;

class IntrinsicProperty;
def IntrNoMem : IntrinsicProperty;
def IntrHasSideEffects : IntrinsicProperty;
def IntrReadMem : IntrinsicProperty;
def IntrArgMemOnly : IntrinsicProperty;
def IntrInaccessibleMemOnly : IntrinsicProperty;
def IntrInaccessibleMemOrArgMemOnly : IntrinsicProperty;


class Intrinsic<list<LLVMType> ret_types,
                list<LLVMType> param_types = [],
                list<IntrinsicProperty> intr_properties = [],
                string name = "",
                list<SDNodeProperty> sd_properties = []> : SDPatternOperator {
  string LLVMName = name;
  string TargetPrefix = "";
  list<LLVMType> RetTypes = ret_types;
  list<LLVMType> ParamTypes = param_types;
  list<IntrinsicProperty> IntrProperties = intr_properties;
  let Properties = sd_properties;

  bit isTarget = 0;
}

// ... these intrinsic.

// CHECK: 1, // llvm.random.gen.no.mem
// CHECK: 2, // llvm.random.gen.read.arg.mem
// CHECK: 3, // llvm.random.gen.read.inaccessible.mem
// CHECK: 4, // llvm.random.gen.read.inaccessible.mem.or.arg.mem
// CHECK: 5, // llvm.random.gen.read.mem

// CHECK: case 5:
// CHECK-NEXT: Atts[] = {Attribute::NoUnwind}
def int_random_gen_read_mem
    : Intrinsic<[llvm_i32_ty], [], [IntrReadMem, IntrHasSideEffects]>;

// CHECK: case 4:
// CHECK-NEXT: Atts[] = {Attribute::NoUnwind}
def int_random_gen_read_inaccessible_mem_or_arg_mem
    : Intrinsic<[llvm_i32_ty], [], [IntrReadMem,IntrInaccessibleMemOrArgMemOnly,
                                    IntrHasSideEffects]>;

// CHECK: case 2:
// CHECK-NEXT: Atts[] = {Attribute::NoUnwind}
def int_random_gen_read_arg_mem
    : Intrinsic<[llvm_i32_ty], [llvm_ptr_ty], [IntrReadMem, IntrArgMemOnly,
                                               IntrHasSideEffects]>;

// CHECK: case 3:
// CHECK-NEXT: Atts[] = {Attribute::NoUnwind}
def int_random_gen_read_inaccessible_mem
    : Intrinsic<[llvm_i32_ty], [], [IntrReadMem, IntrInaccessibleMemOnly,
                                    IntrHasSideEffects]>;

// CHECK: case 1:
// CHECK-NEXT: Atts[] = {Attribute::NoUnwind}
def int_random_gen_no_mem
    : Intrinsic<[llvm_i32_ty], [], [IntrNoMem, IntrHasSideEffects]>;
