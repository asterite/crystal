require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    attr_accessor :resolved
    attr_accessor :resolved_type

    def resolve(mod)
      visitor = ResolveVisitor.new mod
      self.accept visitor
    end

    def initialize_copy(other)
      resolved = nil
      resolved_type = nil
    end
  end

  class Expressions
    def initialize_copy(other)
      self.expressions = other.expressions.map(&:dup)
    end
  end

  class Def
    def args_length_is(length)
      args.length == length
    end

    def instantiate(scope, arg_types)
      return self if resolved_type

      instance_name = "#{name}$#{arg_types.join '$'}$"

      instance = scope.find_expression instance_name
      if !instance
        instance_args = args.dup
        arg_types.each_with_index { |arg_type, i| instance_args[i].resolved_type = arg_type }
        instance = Def.new instance_name, args, body.dup
      end
      instance
    end
  end

  class UnknownType
    def self.find_method(name)
      UnknownMethod
    end
  end

  class UnknownMethod
    def self.args_length_is(length)
      true
    end

    def self.instantiate(scope, arg_types)
      self
    end

    def self.resolved_type
      UnknownType
    end

    def self.accept(visitor)
    end
  end

  class ResolveVisitor < Visitor
    attr_accessor :resolved

    def initialize(scope)
      @scope = scope
    end

    def visit_expressions(node)
      return if node.expressions.empty?

      node.expressions.each { |exp| exp.accept self }
      node.resolved_type = node.expressions.last.resolved_type
    end

    def visit_true(node)
      node.resolved_type = True
    end

    def visit_int(node)
      node.resolved_type = Int
    end

    def visit_def(node)
      @scope.add_expression node

      if node.body
        with_new_scope DefScope.new(@scope, node) do
          node.body.accept self
        end
        node.resolved_type = node.body.resolved_type
      end
      false
    end

    def visit_ref(node)
      return if node.resolved_type

      exp = @scope.find_expression(node.name) or raise "Error: undefined local variable or method '#{node.name}'"
      if exp.is_a?(Def) && !exp.args_length_is(0)
        raise "Error: wrong number of arguments (0 for #{exp.args.length})"
      end

      node.resolved = exp
      exp.accept self

      node.resolved_type = exp.resolved_type
    end

    def visit_call(node)
      return if node.resolved_type

      resolve_method_call node if node.obj
      resolve_function_call node

      false
    end

    def resolve_method_call(node)
      node.obj.accept self
      resolved_type = node.obj.resolved_type

      exp = @scope.find_expression "#{resolved_type}##{node.name}"
      if !exp
        exp = resolved_type.find_method(node.name) or raise "Error: undefined method '#{node.name}' for #{resolved_type}"
        @scope.add_expression exp
      end

      if !exp.args_length_is(node.args.length + 1) # With self
        raise "Error: wrong number of arguments (#{node.args.length} for #{exp.args.length})"
      end

      node.args = [node.obj] + node.args
      node.name = exp.name
      node.obj = nil
    end

    def resolve_function_call(node)
      # This is to prevent recursive resolutions
      node.resolved_type = UnknownType

      node.args.each { |arg| arg.accept self }

      exp = @scope.find_expression(node.name) or raise "Error: undefined method '#{node.name}'"
      if exp.is_a? Var
        # Maybe it's foo -1, which is parsed as a call "foo(-1)" but can be understood as "foo - 1"
        if node.args.length == 1 && node.args[0].is_a?(Int) && node.args[0].has_sign?
          node.resolved = exp
          node.resolved_type = exp.resolved_type
          return false
        else
          raise "Error: undefined method #{node.name}"
        end
      end

      if !exp.args_length_is(node.args.length)
        raise "Error: wrong number of arguments (#{node.args.length} for #{exp.args.length})"
      end

      # If it's already resolved that means it's an intrinsic function
      instance = exp.instantiate @scope, node.args.map(&:resolved_type)

      node.resolved = instance
      instance.accept self

      node.resolved_type = instance.resolved_type

      if node.resolved_type != UnknownType
        # Resolve any expressions with unknown types
        node.args.each do |arg|
          if arg.resolved_type == UnknownType
            arg.resolved_type = nil
            arg.resolved = nil
            arg.accept self
          end
        end
      end
    end

    def visit_if(node)
      node.then.accept self
      node.else.accept self
      node.resolved_type = merge_types(node.then.resolved_type, node.else.resolved_type)
    end

    def merge_types(type1, type2)
      if type1 == UnknownType
        type2
      else
        type1
      end
    end

    def with_new_scope(scope)
      old_scope = @scope
      @scope = scope
      yield
      @scope = old_scope
    end
  end

  class DefScope
    def initialize(scope, a_def)
      @scope = scope
      @def = a_def
    end

    def add_expression(node)
      @scope.add_expression node
    end

    def find_expression(name)
      arg = @def.args.select{|arg| arg.name == name}.first
      return arg if arg

      @scope.find_expression name
    end

    def module
      @scope.module
    end

    def builder
      @scope.builder
    end
  end
end
