require 'llvm/core'
require 'llvm/core/builder'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'

LLVM.init_x86

module Crystal
  class ASTNode
    attr_accessor :code
  end

  class Module
    attr_reader :module
    attr_reader :builder
    attr_reader :fpm

    def initialize
      @symbols = {}
      @expressions = {}
      @module = LLVM::Module.create ''
      @builder = LLVM::Builder.create
      @engine = LLVM::ExecutionEngine.create_jit_compiler @module
      create_function_pass_manager
    end

    def find_symbol(name)
      @symbols[name]
    end

    def add_expression(node)
      @expressions[node.name] = node
    end

    def find_expression(name)
      @expressions[name]
    end

    def run(fun)
      @engine.run_function(fun).to_i LLVM::Int.type
    end

    private

    def create_function_pass_manager
      @fpm = LLVM::FunctionPassManager.new @engine, @module
      @fpm << :instcombine
      @fpm << :reassociate
      @fpm << :gvn
      @fpm << :simplifycfg
    end
  end

  class Int
    def codegen(mod)
      @code ||= LLVM::Int value
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
          @code ||= mod.builder.#{method} left.codegen(mod), right.codegen(mod), '#{node.to_s.downcase}tmp'
        end
      end
    )
  end

  class Def
    def codegen(mod)
      @code ||= begin
        ret_type = body ? LLVM::Int : LLVM::Type.void

        fun = mod.module.functions.named name
        mod.module.functions.delete fun if fun

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
        #fun.dump
        fun
      end
    end
  end

  class Ref
    def codegen(mod)
      @code ||= begin
        fun = mod.module.functions.named(name)
        fun = mod.module.functions.add name, [], LLVM::Int unless fun
        mod.builder.call fun
      end
    end
  end

  class Call
    def codegen(mod)
      @code ||= begin
        fun = mod.module.functions.named(name)
        fun = mod.module.functions.add name, [], LLVM::Int unless fun
        mod.builder.call fun
      end
    end
  end
end
