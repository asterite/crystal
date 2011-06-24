['core', 'core/builder', 'execution_engine', 'transforms/scalar'].each do |filename|
  #require(File.expand_path("../../../../ruby-llvm/lib/llvm/#{filename}",  __FILE__))
  require "llvm/#{filename}"
end

LLVM.init_x86

module Crystal
  DefaultType = LLVM::Int
  def self.DefaultType(*args); LLVM::Int(*args); end

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
      @engine.run_function(fun).to_i Crystal::DefaultType.type
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
      @code ||= Crystal::DefaultType value
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

  [
    [LT, "slt"],
  ].each do |node, method|
    eval %Q(
      class #{node}
        def codegen(mod)
          @code ||= begin
            cond = mod.builder.icmp :#{method}, left.codegen(mod), right.codegen(mod), '#{node.to_s.downcase}tmp'
            mod.builder.zext(cond, Crystal::DefaultType, 'booltmp')
          end
        end
      end
    )
  end

  class Def
    def codegen(mod)
      @code ||= begin
        ret_type = body ? Crystal::DefaultType : LLVM::Type.void

        fun = mod.module.functions.named name
        mod.module.functions.delete fun if fun

        args_types = Array.new(args.length, Crystal::DefaultType)
        fun = mod.module.functions.add name, args_types, ret_type
        args.each_with_index do |arg, i|
          arg.code = fun.params[i]
          fun.params[i].name = arg.name
        end

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
      block = mod.builder.get_insert_block

      resolved.codegen mod

      case resolved
      when Arg
        resolved.code
      when Def
        mod.builder.position_at_end block
        mod.builder.call resolved.code
      end
    end
  end

  class Call
    def codegen(mod)
      @code ||= begin
        block = mod.builder.get_insert_block

        resolved.codegen mod

        args = self.args.map{|arg| arg.codegen(mod)}.push('calltmp')

        mod.builder.position_at_end block
        mod.builder.call resolved.code, *args
      end
    end
  end

  class Arg
    def codegen(mod)
      code
    end
  end
end
