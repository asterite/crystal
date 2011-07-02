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

    def remember_block
      block = builder.insert_block
      code = yield
      builder.position_at_end block
      code
    end

    def add_expression(node)
      @expressions["##{node.name}"] = node
    end

    def add_c_expression(node)
      @expressions["#{node.name}"] = node
    end

    def find_expression(name)
      @expressions["##{name}"]
    end

    def find_c_expression(name)
      @expressions[name]
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
      @fpm << :simplifycfg
    end

    def define_builtin_classes
      define_class_class
      define_c_class
      define_bool_class
      define_int_class
    end

    def define_class_class
      klass = define_class Class.new("Class")
    end

    def define_c_class
      klass = add_expression Class.new("C")
      klass.metaclass = CMetaclass.new self
      klass.define_method :'class', Def.new("#{klass.name}#class", [Var.new("self")], klass.metaclass)
      klass
    end

    def define_bool_class
      bool = define_class BoolClass.new("Bool")
      bool.metaclass.primitive = bool
      bool.define_intrinsic(:'==', [bool, bool], bool) { |mod, fun| mod.builder.icmp :eq, fun.params[0], fun.params[1], 'eqtmp' }
    end

    def define_int_class
      bool = find_expression "Bool"
      int = define_class IntClass.new("Int")
      int.metaclass.primitive = int
      int.define_method :'+@', Def.new("Int#+@", [Var.new("self")], Ref.new("self"))
      int.define_method :'-@', Def.new("Int#-@", [Var.new("self")], Call.new(Int.new(0), :'-', Ref.new("self")))
      int.define_intrinsic(:'+', [int, int], int) { |mod, fun| mod.builder.add fun.params[0], fun.params[1], 'addtmp' }
      int.define_intrinsic(:'-', [int, int], int) { |mod, fun| mod.builder.sub fun.params[0], fun.params[1], 'subtmp' }
      int.define_intrinsic(:'*', [int, int], int) { |mod, fun| mod.builder.mul fun.params[0], fun.params[1], 'multmp' }
      int.define_intrinsic(:'/', [int, int], int) { |mod, fun| mod.builder.sdiv fun.params[0], fun.params[1], 'sdivtmp' }
      int.define_intrinsic(:'<', [int, int], bool) { |mod, fun| mod.builder.icmp :slt, fun.params[0], fun.params[1], 'slttmp' }
      int.define_intrinsic(:'<=', [int, int], bool) { |mod, fun| mod.builder.icmp :sle, fun.params[0], fun.params[1], 'sletmp' }
      int.define_intrinsic(:'>', [int, int], bool) { |mod, fun| mod.builder.icmp :sgt, fun.params[0], fun.params[1], 'sgttmp' }
      int.define_intrinsic(:'>=', [int, int], bool) { |mod, fun| mod.builder.icmp :sge, fun.params[0], fun.params[1], 'sgetmp' }
      int.define_intrinsic(:'==', [int, int], bool) { |mod, fun| mod.builder.icmp :eq, fun.params[0], fun.params[1], 'eqtmp' }
    end

    def define_class(klass)
      klass = add_expression klass
      klass.define_method :'class', Def.new("#{klass.name}#class", [Var.new("self")], klass.metaclass)
      klass
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

  class Intrinsic < Def
    def initialize(name, arg_types, resolved_type, &block)
      @name = name
      @args = arg_types.each_with_index.map { |type, i| Var.new("x#{i}", type) }
      @resolved_type = resolved_type
      @block = block
    end

    def codegen_body(mod, fun)
      @block.call mod, fun
    end

    def optimize(fun)
      fun.linkage = :private
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

    def metaclass
      @metaclass ||= Class.new(name)
    end

    def metaclass=(klass)
      @metaclass = klass
    end

    def primitive=(primitive)
      @primitive = primitive
    end

    def primitive
      @primitive or raise "Can't map #{self} to a C type"
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

  class BoolClass < Class
    def llvm_type
      LLVM::Int1
    end

    def llvm_cast(value)
      value.to_b
    end
  end

  class IntClass < Class
    def llvm_type
      LLVM::Int
    end

    def llvm_cast(value)
      value.to_i LLVM::Int.type
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
      fun = mod.module.functions.add name, args_types, resolved_type.llvm_type
      args.each_with_index do |arg, i|
        arg.code = fun.params[i]
        fun.params[i].name = arg.name
      end

      @code = fun

      optimize fun

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
