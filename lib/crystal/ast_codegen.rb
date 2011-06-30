['core', 'core/builder', 'execution_engine', 'transforms/scalar'].each do |filename|
  require "llvm/#{filename}"
end

LLVM.init_x86
LLVM::load_library(File.expand_path('../../../ext/libcrystal.bundle', __FILE__))

module Crystal
  class ASTNode
    attr_accessor :code
  end

  class Module
    attr_reader :module
    attr_reader :builder
    attr_reader :fpm

    def initialize
      @expressions = {}
      @module = LLVM::Module.new ''
      @builder = LLVM::Builder.new
      @engine = LLVM::JITCompiler.new @module
      create_function_pass_manager
      define_exteranl_functions
    end

    def remember_block
      block = builder.insert_block
      code = yield
      builder.position_at_end block
      code
    end

    def add_expression(node)
      @expressions[node.name] = node
    end

    def find_expression(name)
      @expressions[name]
    end

    def run(fun)
      result = @engine.run_function(fun.code)
      fun.resolved_type.llvm_cast result
    end

    private

    def create_function_pass_manager
      @fpm = LLVM::FunctionPassManager.new @engine, @module
      @fpm << :instcombine
      @fpm << :reassociate
      @fpm << :gvn
      @fpm << :simplifycfg
    end

    def define_exteranl_functions
      add_expression Prototype.new("putb", [Bool], Bool)
      add_expression Prototype.new("puti", [Int], Int)
    end
  end

  class Expressions
    def codegen(mod)
      if expressions.empty?
        LLVM::Int 0
      else
        last = nil
        expressions.each do |exp|
          last = exp.codegen mod
        end
        last
      end
    end
  end

  class Bool
    def self.llvm_type
      LLVM::Int1
    end

    def self.llvm_cast(value)
      value.to_b
    end

    def codegen(mod)
      LLVM::Int1.from_i(value ? 1 : 0)
    end
  end

  class Int
    def self.llvm_type
      LLVM::Int
    end

    def codegen(mod)
      LLVM::Int value.to_i
    end

    def self.llvm_cast(value)
      value.to_i LLVM::Int.type
    end
  end

  class Prototype
    def codegen(mod)
      @code ||= mod.module.functions.add(name, @arg_types.map(&:llvm_type), resolved_type.llvm_type)
    end
  end

  class Def
    def codegen(mod)
      return @code if @code

      fun = mod.module.functions.named name
      mod.module.functions.delete fun if fun

      args_types = args.map { |arg| arg.resolved_type.llvm_type }
      fun = mod.module.functions.add name, args_types, resolved_type.llvm_type
      args.each_with_index do |arg, i|
        arg.code = fun.params[i]
        fun.params[i].name = arg.name
      end

      @code = fun

      entry = fun.basic_blocks.append 'entry'

      mod.builder.position_at_end entry
      code = codegen_body(mod, fun)

      mod.builder.ret code

      #fun.dump

      fun.verify
      mod.fpm.run fun
      #fun.dump
      fun
    end

    def codegen_body(mod, fun)
      body.codegen(mod)
    end
  end

  class Ref
    def codegen(mod)
      code = mod.remember_block { resolved.codegen mod }

      case resolved
      when Var
        code
      when Def
        mod.builder.call code
      end
    end
  end

  class Call
    def codegen(mod)
      if resolved.is_a? Var
        mod.builder.add resolved.code, args[0].codegen(mod), 'addtmp'
        # Case when the call is "foo -1" but foo is an arg, not a call
        #Add.new(resolved, args[0]).codegen mod
      else
        resolved_code = mod.remember_block { resolved.codegen mod }
        resolved_args = self.args.map do |arg|
          mod.remember_block { arg.codegen(mod) }
        end
        resolved_args.push('calltmp')

        mod.builder.call resolved_code, *resolved_args
      end
    end
  end

  class Var
    def codegen(mod)
      code
    end
  end

  class If
    def codegen(mod)
      cond_code = cond.codegen mod
      cond_code = mod.builder.icmp(:ne, cond_code, LLVM::Int1.from_i(0), 'ifcond')

      start_block = mod.builder.insert_block
      fun = start_block.parent

      then_block = fun.basic_blocks.append 'then'
      mod.builder.position_at_end then_block
      then_code = self.then.codegen mod
      new_then_block = mod.builder.insert_block

      else_block = fun.basic_blocks.append 'else'
      mod.builder.position_at_end else_block
      else_code = self.else.codegen mod
      new_else_block = mod.builder.insert_block

      merge_block = fun.basic_blocks.append 'merge'
      mod.builder.position_at_end merge_block
      phi = mod.builder.phi LLVM::Int.type, {new_then_block => then_code, new_else_block => else_code}, 'iftmp'

      mod.builder.position_at_end start_block
      mod.builder.cond cond_code, then_block, else_block

      mod.builder.position_at_end new_then_block
      mod.builder.br merge_block

      mod.builder.position_at_end new_else_block
      mod.builder.br merge_block

      mod.builder.position_at_end merge_block

      phi
    end
  end
end
