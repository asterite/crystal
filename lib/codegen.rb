require 'llvm/core'
require 'llvm/core/builder'
require 'llvm/execution_engine'

LLVM.init_x86

class Module
  def initialize
    @module = LLVM::Module.create ''
    @builder = LLVM::Builder.create
  end

  def define(node)
    node.codegen(@builder)
  end
end

class Int
  def codegen(builder)
    LLVM::Int value
  end
end

class Add
  def codegen(builder)
    builder.fadd left.codegen(builder), right.codegen(builder), 'addtmp'
  end
end
