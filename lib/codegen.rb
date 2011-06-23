require 'llvm/core'
require 'llvm/core/builder'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

LLVM.init_x86

class Module
  attr_reader :module
  attr_reader :builder
  attr_reader :fpm

  def initialize
    @module = LLVM::Module.create ''
    @builder = LLVM::Builder.create
    @engine = LLVM::ExecutionEngine.create_jit_compiler @module
    @fpm = LLVM::FunctionPassManager.new @engine, @module
    @fpm << :instcombine
    @fpm << :reassociate
    @fpm << :gvn
    @fpm << :simplifycfg
  end

  def define(node)
    node = Def.new "", [], node unless node.is_a? Def
    node.codegen self
  end

  def eval(node)
    @engine.run_function(define node).to_f LLVM::Double.type
  end
end

class Int
  def codegen(mod)
    LLVM::Double value
  end
end

[Add, Sub, Mul, Div].each do |node|
  eval %Q(
    class #{node}
      def codegen(mod)
        mod.builder.f#{node.to_s.downcase} left.codegen(mod), right.codegen(mod), '#{node.to_s.downcase}tmp'
      end
    end
  )
end

class Def
  def codegen(mod)
    fun = mod.module.functions.add name, [], LLVM::Double
    entry = fun.basic_blocks.append 'entry'
    mod.builder.position_at_end entry
    mod.builder.ret body.codegen(mod)
    fun.verify
    mod.fpm.run fun
    #fun.dump
    fun
  end
end
