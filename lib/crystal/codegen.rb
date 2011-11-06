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
      @classes = {}
      @methods = {}
      @local_vars = {}
      @def_instances = {}
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
      prelude_file = File.expand_path('../../../std/prelude.cr', __FILE__)
      self.eval File.read(prelude_file)
    end
  end

  class Expressions
    def codegen(mod)
      last = nil
      expressions.each do |exp|
        last = exp.codegen mod
      end
      last
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

                  mod.module.functions.add(name, arg_types.map { |x| x.llvm_type(mod) }, resolved_type.llvm_type(mod))
                end
    end
  end

  class Def
    def codegen(mod)
      return @code if @code

      fun = mod.module.functions.named name
      mod.module.functions.delete fun if fun

      args_types = define_args_types mod

      fun = mod.module.functions.add name, args_types, resolved_type.llvm_type(mod)
      @code = fun

      define_optimizations fun

      entry = fun.basic_blocks.append 'entry'
      mod.builder.position_at_end entry

      define_args args_types, mod

      define_local_vars mod
      load_context(mod) if is_block?

      code = codegen_body(mod, fun)
      mod.builder.ret(body.resolved_type == mod.nil_class ? nil : code) unless body.returns?

      fun.verify
      mod.fpm.run fun

      # fun.dump
      fun
    end

    def define_local_vars(mod)
      @local_vars.each { |name, var| var.alloca(mod) }
    end

    def define_args_types(mod)
      args_types = args.map { |arg| arg.resolved_type.llvm_type(mod) }
      if block
        args_types << LLVM::Pointer(LLVM::Int8)
        args_types << block.llvm_type(mod)
      elsif is_block?
        args_types << LLVM::Pointer(LLVM::Int8)
      end
      args_types
    end

    def define_args(args_types, mod)
      args.each_with_index do |arg, i|
        param = @code.params[i]
        param.name = arg.name
        arg.code = mod.builder.alloca args_types[i], param.name
        mod.builder.store param, arg.code
      end

      if block
        @code.params[-2].name = "&context"
        @code.params[-1].name = "&block"
      elsif is_block?
        @code.params[-1].name = "&context"
      end
    end

    def llvm_type(mod)
      arg_types = args.map { |x| x.resolved_type.llvm_type(mod) }
      arg_types << LLVM::Pointer(LLVM::Int8)
      return_type = resolved_type.llvm_type(mod)
      LLVM::Pointer LLVM::Function(arg_types, return_type)
    end

    def is_block?
      !context.nil?
    end

    def load_context(mod)
      context.casted_context = mod.builder.bit_cast @code.params[-1], context.pointer_type(mod), '&casted_context'
      context.loaded_context = mod.builder.load context.casted_context, '&loaded_context'
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
      when Var
        # Case when the call is "foo -1" but foo is an arg, not a call
        call = Call.new(resolved, :'+', [args[0]])
        call.resolve mod
        call.codegen mod
      else
        resolved_code = mod.remember_block { resolved.codegen mod }
        resolved_args = self.args.map { |arg| mod.remember_block { arg.codegen(mod) } }
        resolved_args.insert 0, obj.codegen(mod) if obj && !resolved.is_a?(Prototype)

        if resolved_block
          context_ptr, casted_context_ptr = resolved_block.context.alloca mod
          resolved_args << casted_context_ptr

          fun_pointer = mod.remember_block { resolved_block.codegen mod }
          resolved_args << fun_pointer
        end
        resolved_args.push('calltmp') if resolved.resolved_type != mod.nil_class

        call_result = mod.builder.call resolved_code, *resolved_args
        check_block_return context_ptr, mod if resolved_block && resolved_block.context.returns?
        call_result
      end
    end

    def check_block_return(context_ptr, mod)
      start_block = mod.builder.insert_block
      fun = start_block.parent

      normal_block = fun.basic_blocks.append 'normal'
      return_block = fun.basic_blocks.append 'return'

      context = mod.builder.load context_ptr, 'context'
      exit_flag = mod.builder.extract_value context, 0, 'exit_flag'

      mod.builder.switch exit_flag, normal_block, {Yield::ExitReturn => return_block}

      mod.builder.position_at_end return_block

      if parent_def.resolved_type == resolved_block.context.return_type
        return_value = mod.builder.extract_value context, resolved_block.context.return_index, 'return_value'

        if parent_context = parent_def.context
          parent_context.return_from_block return_value, fun, mod
        end

        mod.builder.ret return_value
      else
        mod.builder.ret parent_def.resolved_type.codegen_default(mod)
      end

      mod.builder.position_at_end normal_block
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
      @code = mod.builder.alloca resolved_type.llvm_type(mod), name
    end
  end

  class If
    def codegen(mod)
      cond_code = mod.builder.icmp(:ne, cond.codegen(mod), LLVM::Int1.from_i(0), 'ifcond')

      start_block = mod.builder.insert_block
      fun = start_block.parent

      then_block = fun.basic_blocks.append 'then'
      mod.builder.position_at_end then_block
      then_code = self.then.codegen mod
      then_code = self.else.resolved_type.codegen_default mod if !then_code && self.else
      new_then_block = mod.builder.insert_block

      else_block = fun.basic_blocks.append 'else'
      mod.builder.position_at_end else_block
      else_code = self.else.codegen mod
      else_code = self.then.resolved_type.codegen_default mod if !else_code && self.then
      new_else_block = mod.builder.insert_block

      merge_block = fun.basic_blocks.append 'merge'
      mod.builder.position_at_end merge_block

      phi = nil

      if resolved_type != mod.nil_class
        branches = {}
        branches[new_then_block] = then_code unless self.then.returns?
        branches[new_else_block] = else_code unless self.else.returns?
        phi = mod.builder.phi resolved_type.llvm_type(mod), branches, 'iftmp'
      end

      mod.builder.position_at_end start_block
      mod.builder.cond cond_code, then_block, else_block

      unless self.then.returns?
        mod.builder.position_at_end new_then_block
        mod.builder.br merge_block
      end

      unless self.else.returns?
        mod.builder.position_at_end new_else_block
        mod.builder.br merge_block
      end

      if resolved_type == mod.nil_class
        phi = mod.builder.position_at_end merge_block
      else
        mod.builder.position_at_end merge_block
      end

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
      cond_code = mod.builder.icmp(:ne, cond.codegen(mod), LLVM::Int1.from_i(0), 'whilecond')
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
      if target.resolved.is_a?(BlockReference)
        target.resolved.code = target.resolved.codegen_ptr(mod)
      else
        unless target.resolved.code
          target.resolved.code = mod.module.globals.add(resolved_type.llvm_type(mod), target.name)
          target.resolved.code.linkage = :internal
          target.resolved.code.initializer = LLVM::Constant.undef resolved_type.llvm_type(mod)
        end
      end

      mod.builder.store value.codegen(mod), target.resolved.code
      mod.builder.load target.resolved.code, target.name
    end
  end

  class Not
    def codegen(mod)
      mod.builder.not exp.codegen(mod), 'not_tmp'
    end
  end

  class And
    def codegen(mod)
      left_code = mod.builder.icmp :ne, left.codegen(mod), LLVM::Int1.from_i(0), 'left_and_tmp'
      right_code = mod.builder.icmp :ne, right.codegen(mod), LLVM::Int1.from_i(0), 'right_and_tmp'
      mod.builder.and left_code, right_code, 'and_tmp'
    end
  end

  class Or
    def codegen(mod)
      left_code = mod.builder.icmp :ne, left.codegen(mod), LLVM::Int1.from_i(0), 'left_or_tmp'
      right_code = mod.builder.icmp :ne, right.codegen(mod), LLVM::Int1.from_i(0), 'right_or_tmp'
      mod.builder.or left_code, right_code, 'or_tmp'
    end
  end

  class Yield
    ExitType = LLVM::Int32
    ExitPointerType = LLVM::Pointer(LLVM::Int32)

    ExitNormal = LLVM::Int32.from_i 0
    ExitBreak = LLVM::Int32.from_i 1
    ExitReturn = LLVM::Int32.from_i 2

    def codegen(mod)
      start_block = mod.builder.insert_block
      fun = start_block.parent

      normal_block = fun.basic_blocks.append 'normal'
      break_block = fun.basic_blocks.append 'break'

      casted_result = clear_context_exit_flag fun, mod
      yield_result = mod.builder.call fun.params[-1], *(codegen_args fun, mod)

      loaded_result = mod.builder.load casted_result
      mod.builder.switch loaded_result, break_block, {ExitNormal => normal_block}

      mod.builder.position_at_end break_block
      mod.builder.ret(resolved_type != self.def.resolved_type ? self.def.resolved_type.codegen_default(mod) : yield_result)

      mod.builder.position_at_end normal_block

      yield_result
    end

    def clear_context_exit_flag(fun, mod)
      casted_result = mod.builder.bit_cast fun.params[-2], ExitPointerType, 'casted_result_ptr'
      mod.builder.store ExitNormal, casted_result
      casted_result
    end

    def codegen_args(fun, mod)
      resolved_args = args.map { |arg| mod.remember_block { arg.codegen(mod) } }
      resolved_args << fun.params[-2]
      resolved_args << 'yield_result' unless resolved_type == mod.nil_class
      resolved_args
    end
  end

  # A context stores the following:
  #  - A flag to indicate if the block issued a break, next or return
  #  - Pointers to the variables referenced in the immediately superior context
  #  - Pointer to the parent context, if needed
  #  - Return value, if needed
  class BlockContext
    def type(mod)
      @type ||= begin
                  types = []
                  types << Yield::ExitType
                  types += references.values.map { |x| x.llvm_type(mod) }
                  types << LLVM::Pointer(parent.type mod) if parent
                  types << return_type.llvm_type(mod) if returns?

                  type = LLVM::Type.struct types, false
                  mod.module.types.add '$context_type', type
                  type
                end
    end

    def pointer_type(mod)
      LLVM::Pointer type(mod)
    end

    def alloca(mod)
      context = mod.builder.alloca type(mod), '&context'

      i = 1
      references.each do |name, node|
        pointer = mod.builder.inbounds_gep context, [LLVM::Int32.from_i(0), LLVM::Int32.from_i(i)], "#{name}_ptr"
        mod.builder.store node.node.code, pointer
        i += 1
      end

      if parent
        pointer = mod.builder.inbounds_gep context, [LLVM::Int32.from_i(0), LLVM::Int32.from_i(parent_index)], "context_ptr"
        mod.builder.store parent.casted_context, pointer
      end

      casted_context = mod.builder.bit_cast context, LLVM::Pointer(LLVM::Int8), '&casted_context'
      [context, casted_context]
    end

    def index(node)
      value = references.keys.index node.name
      value ? [self, value + 1] : parent.index(node)
    end

    def parent_index
      references.length + 1
    end

    def return_index
      references.length + (parent ? 2 : 1)
    end

    def access_parent(mod, context_ptr)
      parent_context_ptr = mod.builder.extract_value context_ptr, parent_index, "parent_context_ptr"
      mod.builder.load parent_context_ptr, "parent_context"
    end

    def return_from_block(code, fun, mod)
      context_ptr = mod.builder.bit_cast fun.params[-1], pointer_type(mod), 'context_ptr'

      exit_flag_ptr = mod.builder.inbounds_gep context_ptr, [LLVM::Int32.from_i(0),  LLVM::Int32.from_i(0)], "exit_flag_ptr"
      mod.builder.store Yield::ExitReturn, exit_flag_ptr

      if code
        return_ptr = mod.builder.inbounds_gep context_ptr, [LLVM::Int32.from_i(0),  LLVM::Int32.from_i(return_index)], "return_ptr"
        mod.builder.store code, return_ptr
      end
    end
  end

  class BlockReference
    def codegen(mod)
      ptr = codegen_ptr mod
      mod.builder.load ptr
    end

    def codegen_ptr(mod)
      where, index = context.index node
      current = self.context
      parent_context_ptr = context.loaded_context

      while current.object_id != where.object_id
        parent_context_ptr = current.access_parent mod, parent_context_ptr
        current = current.parent
      end

      mod.builder.extract_value parent_context_ptr, index, "#{node.name}_ptr"
    end

    def llvm_type(mod)
      LLVM::Pointer node.resolved_type.llvm_type(mod)
    end
  end

  class Return
    def codegen(mod)
      if in_block?
        start_block = mod.builder.insert_block
        fun = start_block.parent

        context.return_from_block(exp ? exp.codegen(mod) : nil, fun, mod)

        mod.builder.ret(exp && exp.resolved_type == block.resolved_type ? exp.codegen(mod) : block.resolved_type.codegen_default(mod))
      else
        mod.builder.ret(exp ? exp.codegen(mod) : nil)
      end
    end
  end

  class Break
    def codegen(mod)
      start_block = mod.builder.insert_block
      fun = start_block.parent

      casted_result = mod.builder.bit_cast fun.params[-1], Yield::ExitPointerType, 'casted_result_ptr'
      mod.builder.store Yield::ExitBreak, casted_result

      mod.builder.ret(exp ? exp.codegen(mod) : nil)
    end
  end

  class Next
    def codegen(mod)
      mod.builder.ret(exp ? exp.codegen(mod) : nil)
    end
  end
end
