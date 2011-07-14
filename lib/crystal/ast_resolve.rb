require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    attr_accessor :resolved
    attr_accessor :resolved_type

    def resolve(mod)
      visitor = ResolveVisitor.new mod
      self.accept visitor
    end
  end

  class Assign
    attr_accessor :global
  end

  class Prototype
    def args_length_is(length)
      @arg_types.length == length - 1
    end

    def args_length
      @arg_types.length
    end
  end

  class Def
    def args_length_is(length)
      args.length == length
    end

    def args_length
      @args_length || args.length
    end

    def args_length=(value)
      @args_length = value
    end

    def instantiate(scope, call_args)
      return self if resolved_type

      args_types = call_args.map &:resolved_type
      args_types_signature = args_types.join '$'
      args_values = []
      args_values_signature = ""
      args.each_with_index do |arg, i|
        if arg.name[0] == arg.name[0].upcase
          raise "Argument #{arg} must be known at compile time" unless call_args[i].can_be_evaluated_at_compile_time?
          arg_value = scope.eval_anon call_args[i]
          args_values_signature << "$" unless args_values_signature.empty?
          args_values_signature << arg_value.to_s
          args_values << arg_value
        else
          args_values << nil
        end
      end
      instance_name = "#{name}$#{args_types_signature}$#{args_values_signature}$"

      instance = scope.find_expression instance_name
      if !instance
        instance_args = args.map(&:clone)
        instance_args.each_with_index { |arg, index| arg.compile_time_value = args_values[index] }
        args_types.each_with_index { |arg_type, i| instance_args[i].resolved_type = arg_type }
        instance = Def.new instance_name, instance_args, body.clone
      end
      instance
    end
  end

  class Call
    def args_length
      args.length
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
      if node.expressions.empty?
        node.resolved_type = @scope.nil_class
      else
        node.expressions.each { |exp| exp.accept self }
        node.resolved_type = node.expressions.last.resolved_type
      end
      false
    end

    def visit_class(node)
      node.resolved_type = node.type || @scope.class_class
    end

    def visit_nil(node)
      node.resolved_type = @scope.nil_class
    end

    def visit_bool(node)
      node.resolved_type = @scope.bool_class
    end

    def visit_int(node)
      node.resolved_type = @scope.int_class
    end

    def visit_long(node)
      node.resolved_type = @scope.long_class
    end

    def visit_float(node)
      node.resolved_type = @scope.float_class
    end

    def end_visit_prototype(node)
      node.resolved_type = @scope.find_expression node.resolved_type.name
      node.arg_types.map! { |type| @scope.find_expression type.name }
    end

    def visit_def(node)
      @scope.add_expression node

      return false if @scope.is_a?(ClassDefScope)

      if node.body
        with_new_scope DefScope.new(@scope, node) do
          node.body.accept self
        end
        node.resolved_type = node.body.resolved_type
      end
      false
    end

    def visit_class_def(node)
      exp = @scope.find_expression node.name
      raise_error node, "uninitialized constant #{node.name}" unless exp
      raise_error node, "can only extend from Class type" unless exp.class <= Crystal::Class

      with_new_scope ClassDefScope.new(@scope, exp) do
        node.body.eval @scope
      end
      false
    end

    def visit_ref(node)
      return if node.resolved_type

      exp = @scope.find_expression(node.name) or raise_error node, "undefined local variable or method '#{node.name}'"
      if exp.is_a?(Def) || exp.is_a?(Prototype)
        call = Call.new(nil, exp.name)
        call.accept self
        exp = call.resolved
      else
        exp.accept self
      end

      node.resolved = exp
      node.resolved_type = exp.resolved_type
      false
    end

    def visit_assign(node)
      node.value.accept self
      node.target.resolved = @scope.find_expression(node.target.name)

      if node.target.resolved
        unless node.target.resolved.is_a?(Var)
          raise_error node, "can't assign to #{node.target}, it is not a variable"
        end
        if node.value.resolved_type != UnknownType && node.target.resolved.resolved_type != node.value.resolved_type
          raise_error node, "can't assign #{node.value.resolved_type} to #{node.target} of type #{node.target.resolved.resolved_type}"
        end
      else
        var = Var.new(node.target.name, node.value.resolved_type)
        @scope.add_expression var
        node.target.resolved = var
      end

      node.resolved_type = node.value.resolved_type
      node.global = @scope.global?

      false
    end

    def visit_call(node)
      return if node.resolved_type

      # This is to prevent recursive resolutions
      node.resolved_type = UnknownType

      resolve_method_call node if node.obj
      resolve_function_call node

      false
    end

    def resolve_method_call(node)
      node.obj.accept self
      resolved_type = node.obj.resolved_type

      exp = @scope.find_expression "#{resolved_type}##{node.name}"
      if !exp
        exp = resolved_type.find_method(node.name) or raise_error node, "undefined method '#{node.name}' for #{resolved_type}"
        @scope.add_expression exp
      end

      if !exp.args_length_is(node.args_length + 1) # With self
        raise_error node, "wrong number of arguments (#{node.args_length} for #{exp.args_length})"
      end

      node.args = [node.obj] + node.args
      node.name = exp.name
      node.obj = nil
    end

    def resolve_function_call(node)
      node.args.each { |arg| arg.accept self }

      exp = @scope.find_expression(node.name) or raise_error node, "undefined method '#{node.name}'"

      if exp.is_a?(Prototype) || exp.is_a?(Def)
        if !exp.args_length_is(node.args_length)
          raise_error node, "wrong number of arguments (#{node.args_length} for #{exp.args_length})"
        end
      end

      if exp.is_a? Prototype
        node.args.shift

        exp.arg_types.each_with_index do |expected_type, i|
          actual_type = node.args[i].resolved_type
          unless actual_type.subclass_of? expected_type
            raise_error node, "argument number #{i + 1} of C.#{exp.name} must be an #{expected_type}, not #{actual_type}"
          end
        end

        node.resolved = exp
        node.resolved_type = exp.resolved_type
        return false
      end

      if exp.is_a? Var
        # Maybe it's foo -1, which is parsed as a call "foo(-1)" but can be understood as "foo - 1"
        if node.args_length == 1 && node.args[0].is_a?(Int) && node.args[0].has_sign?
          node.resolved = exp
          node.resolved_type = exp.resolved_type
          return false
        else
          raise_error node, "undefined method #{node.name}"
        end
      end

      # If it's already resolved that means it's an intrinsic function
      instance = exp.instantiate @scope, node.args

      node.resolved = instance
      instance.accept self

      node.resolved_type = instance.resolved_type

      if node.resolved_type == UnknownType
        raise_error node, "can't deduce the type of #{instance.name}"
      end

      # Resolve any expressions with unknown types
      node.args.each do |arg|
        if arg.resolved_type == UnknownType
          arg.resolved_type = nil
          arg.resolved = nil
          arg.accept self
        end
      end
    end

    def visit_if(node)
      node.cond.accept self
      raise_error node, "if condition must be Bool" unless node.cond.resolved_type == @scope.bool_class

      node.then.accept self
      node.else.accept self
      node.resolved_type = merge_types(node, node.then.resolved_type, node.else.resolved_type)
      false
    end

    def visit_static_if(node)
      node.cond.accept self
      raise_error node, "If condition must be Bool" unless node.cond.resolved_type == @scope.bool_class
      raise_error node, "can't evaluate If at compile-time" unless node.can_be_evaluated_at_compile_time?

      cond_value = @scope.eval_anon node.cond
      if cond_value.value
        node.then.accept self
        node.parent.replace node, node.then
      else
        node.else.accept self
        node.parent.replace node, node.else
      end
      false
    end

    def visit_while(node)
      node.cond.accept self
      node.body.accept self
      node.resolved_type = @scope.find_expression "Nil"
      false
    end

    def end_visit_and(node)
      node.resolved_type = @scope.bool_class
    end

    def end_visit_or(node)
      node.resolved_type = @scope.bool_class
    end

    def merge_types(node, type1, type2)
      return type2 if type1.nil? || type1 == UnknownType || type1 == @scope.nil_class
      return type1 if type2.nil? || type2 == UnknownType || type2 == @scope.nil_class
      return type1 if type1 == type2
      raise_error node, "if branches have different types: #{type1} and #{type2}"
    end

    def with_new_scope(scope)
      old_scope = @scope
      @scope = scope
      yield
      @scope = old_scope
    end

    def raise_error(node, message)
      raise "Error on line #{node.line_number}: #{message}"
    end
  end

  class Scope
    def method_missing(name, *args)
      @scope.send name, *args
    end
  end

  class DefScope < Scope
    def initialize(scope, a_def)
      @scope = scope
      @def = a_def
      @local_variables = {}
    end

    def global?
      @def.is_a? TopLevelDef
    end

    def add_expression(node)
      if @def.is_a? TopLevelDef
        @scope.add_expression node
      else
        @local_variables[node.name] = node
      end
    end

    def find_expression(name)
      arg = @def.args.select{|arg| arg.name == name}.first
      return arg if arg

      var = @local_variables[name]
      return var if var

      @scope.find_expression name
    end
  end

  class ClassDefScope < Scope
    def initialize(scope, a_class)
      @scope = scope
      @class = a_class
    end

    def global?
      true
    end

    def add_expression(node)
      name = node.name
      node.name = "#{@class.name}##{name}"
      node.args.insert 0, Var.new("self")
      node.args_length = node.args.length - 1
      @class.define_method name, node
    end
  end
end
