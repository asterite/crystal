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
    fun = define node
    if node.is_a? Def
      nil
    else
      @engine.run_function(fun).to_i LLVM::Int.type
    end
  end
end

class Int
  def codegen(mod)
    LLVM::Int value
  end
end

[
  [Add, "add"],
  [Sub, "sub"],
  [Mul, "mul"],
  [Div, "sdiv"]
].each do |node, method|
  eval %Q(
    class #{node}
      def codegen(mod)
        mod.builder.#{method} left.codegen(mod), right.codegen(mod), '#{node.to_s.downcase}tmp'
      end
    end
  )
end

class Def
  def codegen(mod)
    ret_type = body ? LLMV::Int : LLVM::Type.void

    fun = mod.module.functions.add name, [], ret_type
    entry = fun.basic_blocks.append 'entry'
    mod.builder.position_at_end entry

    if body
      mod.builder.ret body.codegen(mod)
    else
      mod.builder.ret_void
    end

    fun.verify
    mod.fpm.run fun
    fun.dump
    fun
  end
end
