['core', 'core/builder', 'execution_engine', 'transforms/scalar'].each do |filename|
  require "llvm/#{filename}"
end

LLVM.init_x86
if RUBY_PLATFORM =~ /darwin/
  LLVM::load_library(File.expand_path('../../../ext/libcrystal.bundle', __FILE__))
else
  LLVM::load_library(File.expand_path('../../../ext/libcrystal.so', __FILE__))
end

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
      define_builtin_classes
      load_prelude
    end

    def define_at_top_level(exp)
      @top_level_expressions_count ||= 0
      @top_level_expressions_count += 1

      anon_def = TopLevelDef.new "&main#{@top_level_expressions_count}", [], [exp]
      anon_def.resolve self
      anon_def.codegen self
      anon_def
    end

    def define_block(block)
      @blocks_count ||= 0
      @blocks_count += 1

      block_def = Def.new "&block#{@blocks_count}", block.args, block.body
      block_def.context = BlockContext.new block.scope
      block_def.compile self
      block_def
    end

    def eval_anon(exp)
      remember_block do
        anon_def = Def.new "&anon", [], [exp]
        anon_def.resolve self
        anon_def.codegen self
        run anon_def
      end
    end

    def remember_block
      if block = builder.insert_block
        code = yield
        builder.position_at_end block
        code
      else
        yield
      end
    end

    def add_expression(node, name = node.name)
      @expressions["##{name}"] = node
    end

    def remove_expression(node)
      @expressions.delete "##{node.name}"
    end

    def find_expression(name)
      @expressions["##{name}"]
    end

    def run(fun)
      result = @engine.run_function(fun.code)
      fun.resolved_type.llvm_cast result
    end

    def create_main
      funcs = @module.functions.select { |f| f.name.start_with? '&main' }

      main = @module.functions.add 'main', [], LLVM::Int

      entry = main.basic_blocks.append 'entry'
      @builder.position_at_end entry

      funcs.each { |fun| @builder.call fun }
      @builder.ret LLVM::Int(0)
    end

    def dump
      @module.dump
    end

    private

    def create_function_pass_manager
      @fpm = LLVM::FunctionPassManager.new @engine, @module
      @fpm << :instcombine
      @fpm << :reassociate
      @fpm << :gvn
      @fpm << :mem2reg
      @fpm << :simplifycfg
    end

    def load_prelude
      prelude_file = File.expand_path('../../../lib/crystal/prelude.cr', __FILE__)
      self.eval File.read(prelude_file)
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

  class Nil
    def codegen(mod)
      nil
    end
  end

  class Bool
    def codegen(mod)
      LLVM::Int1.from_i(value ? 1 : 0)
    end
  end

  class Int
    def codegen(mod)
      LLVM::Int value.to_i
    end
  end

  class Float
    def codegen(mod)
      LLVM::Float value.to_f
    end
  end

  class Char
    def codegen(mod)
      LLVM::Int8.from_i value.ord
    end
  end

  class Prototype
    def codegen(mod)
      @code ||= begin
                  fun = mod.module.functions.named name
                  mod.module.functions.delete fun if fun

                  mod.module.functions.add(name, arg_types.map(&:llvm_type), resolved_type.llvm_type)
                end
    end
  end

  class Def
    def codegen(mod)
      return @code if @code

      fun = mod.module.functions.named name
      mod.module.functions.delete fun if fun

      args_types = args.map { |arg| arg.resolved_type.llvm_type }
      if block
        args_types << LLVM::Pointer(LLVM::Int8)
        args_types << block.llvm_type(mod)
      elsif is_block?
        args_types << LLVM::Pointer(LLVM::Int8)
      end

      fun = mod.module.functions.add name, args_types, resolved_type.llvm_type
      @code = fun

      define_optimizations fun

      entry = fun.basic_blocks.append 'entry'
      mod.builder.position_at_end entry

      args.each_with_index do |arg, i|
        param = fun.params[i]
        param.name = arg.name
        arg.code = mod.builder.alloca args_types[i], param.name
        mod.builder.store param, arg.code
      end

      if block
        fun.params[fun.params.size - 2].name = "&context"
        fun.params[fun.params.size - 1].name = "&block"
      elsif is_block?
        fun.params[fun.params.size - 1].name = "&context"
      end

      if is_block?
        casted_context = mod.builder.bit_cast fun.params[fun.params.size - 1], context.pointer_type(mod), '&casted_context'
        loaded_context = mod.builder.load casted_context, '&loaded_context'
        context.loaded_context = loaded_context
      end

      define_local_variables mod

      code = codegen_body(mod, fun)
      if body.resolved_type == mod.nil_class
        mod.builder.ret_void
      else
        mod.builder.ret code
      end

      # fun.dump

      fun.verify
      mod.fpm.run fun

      # fun.dump
      fun
    end

    def define_local_variables(mod)
      @local_variables.each { |name, var| var.alloca(mod) }
    end

    def llvm_type(mod)
      arg_types = args.map { |x| x.resolved_type.llvm_type }
      arg_types << LLVM::Pointer(LLVM::Int8)
      return_type = resolved_type.llvm_type
      LLVM::Pointer LLVM::Function(arg_types, return_type)
    end

    def is_block?
      !context.nil?
    end

    def define_optimizations(fun)
    end

    def codegen_body(mod, fun)
      body.codegen(mod)
    end
  end

  class Ref
    def codegen(mod)
      code = mod.remember_block { resolved.codegen mod }

      case resolved
      when Def
        mod.builder.call code
      else
        code
      end
    end
  end

  class Call
    def codegen(mod)
      case resolved
      when Class
        LLVM::Int64.from_i resolved.object_id
      when Var
        # Case when the call is "foo -1" but foo is an arg, not a call
        call = Call.new(resolved, :'+', [args[0]])
        call.resolve mod
        call.codegen mod
      else
        resolved_code = mod.remember_block { resolved.codegen mod }
        resolved_args = self.args.map do |arg|
          mod.remember_block { arg.codegen(mod) }
        end

        if resolved_block
          context = resolved_block.context.alloca(mod)
          resolved_args << context

          fun = mod.remember_block { resolved_block.codegen(mod) }
          resolved_args << fun
        end
        resolved_args.push('calltmp') if resolved.resolved_type != mod.nil_class

        mod.builder.call resolved_code, *resolved_args
      end
    end
  end

  class Var
    def codegen(mod)
      if compile_time_value
        compile_time_value.codegen mod
      else
        mod.builder.load code, name
      end
    end

    def alloca(mod)
      @code = mod.builder.alloca(resolved_type.llvm_type, name)
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
      phi = mod.builder.phi resolved_type.llvm_type, {new_then_block => then_code, new_else_block => else_code}, 'iftmp'

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

  class While
    def codegen(mod)
      start_block = mod.builder.insert_block
      fun = start_block.parent

      while_block = fun.basic_blocks.append 'while'
      while_body_block = fun.basic_blocks.append 'while_body'
      while_exit_block = fun.basic_blocks.append 'while_exit'

      mod.builder.position_at_end while_block
      cond_code = cond.codegen mod
      cond_code = mod.builder.icmp(:ne, cond_code, LLVM::Int1.from_i(0), 'whilecond')
      mod.builder.cond cond_code, while_body_block, while_exit_block

      mod.builder.position_at_end while_body_block
      code = body.codegen mod
      mod.builder.br while_block

      mod.builder.position_at_end start_block
      mod.builder.br while_block

      mod.builder.position_at_end while_exit_block
      code
    end
  end

  class Assign
    def codegen(mod)
      unless target.resolved.code
        target.resolved.code = mod.module.globals.add(resolved_type.llvm_type, target.name)
        target.resolved.code.linkage = :internal
        target.resolved.code.initializer = LLVM::Constant.undef resolved_type.llvm_type
      end

      mod.builder.store value.codegen(mod), target.resolved.code
      mod.builder.load target.resolved.code, target.name
    end
  end

  class Not
    def codegen(mod)
      exp_code = exp.codegen(mod)
      mod.builder.not exp_code, 'nottmp'
    end
  end

  class And
    def codegen(mod)
      left_code = mod.builder.icmp :ne, left.codegen(mod), LLVM::Int1.from_i(0), 'leftandtmp'
      right_code = mod.builder.icmp :ne, right.codegen(mod), LLVM::Int1.from_i(0), 'rightandtmp'
      mod.builder.and left_code, right_code, 'andtmp'
    end
  end

  class Or
    def codegen(mod)
      left_code = mod.builder.icmp :ne, left.codegen(mod), LLVM::Int1.from_i(0), 'leftandtmp'
      right_code = mod.builder.icmp :ne, right.codegen(mod), LLVM::Int1.from_i(0), 'rightandtmp'
      mod.builder.or left_code, right_code, 'andtmp'
    end
  end

  class BlockCall
    def codegen(mod)
      start_block = mod.builder.insert_block
      fun = start_block.parent

      resolved_args = args.map do |arg|
        mod.remember_block { arg.codegen(mod) }
      end
      resolved_args << fun.params[fun.params.size - 2]

      mod.builder.call fun.params[fun.params.size - 1], *resolved_args
    end
  end

  class BlockContext
    def type(mod)
      @type ||= begin
                  type = LLVM::Type.struct references.values.map(&:llvm_type), false
                  mod.module.types.add '$context_type', type
                  type
                end
    end

    def pointer_type(mod)
      LLVM::Pointer type(mod)
    end

    def alloca(mod)
      context = mod.builder.alloca type(mod), '&context'

      i = 0
      @references.each do |name, node|
        pointer = mod.builder.inbounds_gep context, [LLVM::Int32.from_i(0), LLVM::Int32.from_i(i)], "#{name}_ptr"
        mod.builder.store node.node.code, pointer
        i += 1
      end

      casted_context = mod.builder.bit_cast context, LLVM::Pointer(LLVM::Int8), '&casted_context'
      casted_context
    end
  end

  class BlockReference
    def codegen(mod)
      index = context.index node
      ptr = mod.builder.extract_value context.loaded_context, index, "#{node.name}_ptr"
      mod.builder.load ptr
    end

    def llvm_type
      LLVM::Pointer node.resolved_type.llvm_type
    end
  end
end
