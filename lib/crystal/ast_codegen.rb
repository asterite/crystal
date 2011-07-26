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
      $module = self

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

      anon_def = TopLevelDef.new "$main#{@top_level_expressions_count}", [], [exp]
      anon_def.resolve self
      anon_def.codegen self
      anon_def
    end

    def define_block(block)
      @blocks_count ||= 0
      @blocks_count += 1

      block_def = Def.new "$block#{@blocks_count}", block.args, block.body
      block_def.needs_instance = false
      block_def.compile self
      block_def
    end

    def eval_anon(exp)
      remember_block do
        anon_def = Def.new "$anon", [], [exp]
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

    def add_c_expression(node)
      @expressions["#{node.name}"] = node
    end

    def remove_expression(node)
      @expressions.delete "##{node.name}"
    end

    def find_expression(name)
      @expressions["##{name}"]
    end

    def find_c_expression(name)
      @expressions[name]
    end

    def object_class
      @object_class
    end

    def class_class
      @class_class
    end

    def nil_class
      @nil_class
    end

    def bool_class
      @bool_class
    end

    def int_class
      @int_class
    end

    def long_class
      @long_class
    end

    def float_class
      @float_class
    end

    def char_class
      @char_class
    end

    def run(fun)
      result = @engine.run_function(fun.code)
      fun.resolved_type.llvm_cast result
    end

    def create_main
      funcs = @module.functions.select { |f| f.name.start_with? '$main' }

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

    def define_builtin_classes
      define_object_class
      define_class_class
      define_c_class
      define_nil_class
      define_bool_class
      define_int_class
      define_long_class
      define_float_class
      define_char_class
    end

    def define_object_class
      @object_class = define_class Class.new("Object")
    end

    def define_class_class
      @class_class = Class.new "Class", @object_class
      @class_class.define_static_method :class, Def.new("Class#class", [Var.new("self")], @class_class)
      define_class @class_class
    end

    def define_c_class
      klass = add_expression Class.new("C", @object_class, CMetaclass.new(self))
    end

    def define_nil_class
      @nil_class = define_class NilClass.new("Nil", @object_class)
    end

    def define_bool_class
      @bool_class = define_class BoolClass.new("Bool", @object_class)
    end

    def define_int_class
      @int_class = define_class IntClass.new("Int", @object_class)
    end

    def define_long_class
      @long_class = define_class LongClass.new("Long", @object_class)
    end

    def define_float_class
      @float_class = define_class FloatClass.new("Float", @object_class)
    end

    def define_char_class
      @char_class = define_class CharClass.new("Char", @object_class)
    end

    def define_class(klass)
      add_expression klass
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

  class Class
    def llvm_type
      LLVM::Int64
    end

    def codegen(mod)
      LLVM::Int64.from_i object_id
    end

    def llvm_cast(value)
      object_id = value.to_i LLVM::Int64.type
      ObjectSpace._id2ref object_id
    end
  end

  class CMetaclass < Class
    def initialize(mod)
      @mod = mod
      @name = "C"
    end

    def find_method(name)
      @mod.find_c_expression name
    end
  end

  class NilClass < Class
    def llvm_type
      LLVM::Type.void
    end

    def llvm_cast(value)
      Nil.new
    end
  end

  class BoolClass < Class
    def llvm_type
      LLVM::Int1
    end

    def llvm_cast(value)
      Bool.new value.to_b
    end
  end

  class IntClass < Class
    def llvm_type
      LLVM::Int32
    end

    def llvm_cast(value)
      Int.new(value.to_i LLVM::Int32.type)
    end
  end

  class LongClass < Class
    def llvm_type
      LLVM::Int64
    end

    def llvm_cast(value)
      Long.new(value.to_i LLVM::Int64.type)
    end
  end

  class FloatClass < Class
    def llvm_type
      LLVM::Float
    end

    def llvm_cast(value)
      Float.new(value.to_f LLVM::Float.type)
    end
  end

  class CharClass < Class
    def llvm_type
      LLVM::Int8
    end

    def llvm_cast(value)
      Char.new(value.to_i LLVM::Int8.type)
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

                  mod.module.functions.add(name, @arg_types.map(&:llvm_type), resolved_type.llvm_type)
                end
    end
  end

  class Def
    def codegen(mod)
      return @code if @code

      fun = mod.module.functions.named name
      mod.module.functions.delete fun if fun

      args_types = args.map { |arg| arg.resolved_type.llvm_type }
      args_types << block.llvm_type(mod) if block

      fun = mod.module.functions.add name, args_types, resolved_type.llvm_type

      entry = fun.basic_blocks.append 'entry'
      mod.builder.position_at_end entry

      args.each_with_index do |arg, i|
        param = fun.params[i]
        param.name = arg.name
        arg.code = mod.builder.alloca args_types[i], param.name
        mod.builder.store param, arg.code
      end
      fun.params[fun.params.size - 1].name = "&block" if block

      @code = fun

      optimize fun

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

    def llvm_type(mod)
      arg_types = args.map { |x| x.resolved_type.llvm_type }
      return_type = resolved_type.llvm_type
      LLVM::Pointer LLVM::Function(arg_types, return_type)
    end

    def optimize(fun)
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
        if resolved.is_a?(Def) && resolved.block
          fun = mod.remember_block { resolved.block.codegen(mod) }
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
      alloca = target.resolved.code
      unless alloca
        if global
          alloca = target.resolved.code = mod.module.globals.add(resolved_type.llvm_type, target.name)
          alloca.linkage = :internal
          alloca.initializer = LLVM::Constant.undef resolved_type.llvm_type
        else
          alloca = target.resolved.code = mod.builder.alloca(resolved_type.llvm_type, target.name)
        end
      end

      mod.builder.store value.codegen(mod), alloca
      mod.builder.load target.resolved.code
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

      mod.builder.call fun.params[fun.params.size - 1], *resolved_args
    end
  end
end
