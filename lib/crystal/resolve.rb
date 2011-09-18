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
        return_index = nil
        node.expressions.each_with_index do |exp, i|
          exp.accept self
          break return_index = i if exp.returns?
        end
        node.expressions = node.expressions[0 .. return_index] if return_index
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

    def visit_char(node)
      node.resolved_type = @scope.char_class
    end

    def visit_float(node)
      node.resolved_type = @scope.float_class
    end

    def end_visit_prototype(node)
      node.resolved_type = @scope.find_expression node.resolved_type.name
      node.arg_types.map! { |type| @scope.find_expression type.name }
    end

    def visit_def(node)
      return false if node.resolved_type

      @scope.add_expression node

      return false if @scope.is_a?(ClassDefScope)

      if node.body
        if node.context
          with_new_scope BlockScope.new(@scope, node.context) do
            with_new_scope DefScope.new(@scope, node) do
              node.body.accept self
            end
          end
        else
          with_new_scope DefScope.new(@scope, node) do
            node.body.accept self
          end
        end
        node.resolved_type = node.body.resolved_type
      end

      false
    end

    def end_visit_def(node)
      node.check_return_type node.resolved_type unless node.is_block?
    end

    def visit_class_def(node)
      exp = @scope.find_expression node.name
      if exp
        node.raise_error "can only extend from Class type" unless exp.class <= Crystal::Class
      else
        superclass = if node.superclass
                       @scope.find_expression(node.superclass) or node.raise_error "unknown class '#{node.superclass}'"
                     else
                       @scope.object_class
                     end
        exp = Class.new node.name, superclass
        @scope.define_class exp
      end

      with_new_scope ClassDefScope.new(@scope, exp) do
        node.body.eval @scope
      end
      false
    end

    def visit_ref(node)
      return if node.resolved_type

      exp = nil
      self_var = @scope.find_variable 'self'

      if self_var
        exp = self_var.resolved_type.find_method node.name
        if exp
          call = Call.new(@scope.def.obj, node.name)
          call.accept self
          exp = call.resolved
        end
      end

      unless exp
        exp = @scope.find_expression(node.name) or node.raise_error "undefined local variable or method '#{node.name}'"

        if exp.is_a?(Def) || exp.is_a?(Prototype)
          call = Call.new(nil, exp.name)
          call.accept self
          exp = call.resolved
        else
          exp.accept self
        end
      end

      node.resolved = exp
      node.resolved_type = exp.resolved_type
      false
    end

    def visit_assign(node)
      node.value.accept self
      node.target.resolved = @scope.find_expression(node.target.name)

      if node.target.resolved
        unless node.target.resolved.is_a?(Var) || node.target.resolved.is_a?(BlockReference)
          node.raise_error "can't assign to #{node.target}, it is not a variable"
        end
        if node.value.resolved_type != UnknownType && node.target.resolved.resolved_type != node.value.resolved_type
          node.raise_error "can't assign #{node.value.resolved_type} to #{node.target} of type #{node.target.resolved.resolved_type}"
        end
      else
        var = Var.new(node.target.name, node.value.resolved_type)

        @scope.add_expression var
        node.target.resolved = var
      end

      node.resolved_type = node.value.resolved_type

      false
    end

    def visit_call(node)
      return if node.resolved_type

      self_var = @scope.find_variable 'self'
      node.obj = self_var if !node.obj && self_var && self_var.resolved_type.find_method(node.name)

      node.block.scope = @scope if node.block

      # Solve class method at compile-time
      if node.obj && node.name == :class && node.args.empty?
        node.obj.accept self
        node.parent.replace node, node.obj.resolved_type
        return false
      end

      # This is to prevent recursive resolutions
      node.resolved_type = UnknownType

      parent = node.parent
      replacement = resolve_method_call node if node.obj
      if replacement
        parent.replace node, replacement
        return false
      end
      resolve_function_call node

      false
    end

    def resolve_method_call(node)
      node.obj.accept self
      resolved_type = node.obj.resolved_type

      exp = @scope.find_expression "#{resolved_type}##{node.name}"
      unless exp
        exp = resolved_type.find_method(node.name)
        unless exp
          # Special case: rewrite a != b as !(a == b)
          return new_not_equals(node) if node.name == :'!='

          node.raise_error "undefined method '#{node.name}' for #{resolved_type}"
        end

        @scope.add_expression exp
      end

      if !exp.args_length_is(node.args_length + 1) # With self
        node.raise_error "wrong number of arguments (#{node.args_length} for #{exp.args_length})"
      end

      node.args = [node.obj] + node.args
      node.name = exp.name
      nil
    end

    def resolve_function_call(node)
      node.args.each { |arg| arg.accept self }

      exp = @scope.find_expression(node.name) or node.raise_error "undefined method '#{node.name}'"

      if exp.is_a?(Prototype) || exp.is_a?(Def)
        if !exp.args_length_is(node.args_length)
          node.raise_error "wrong number of arguments (#{node.args_length} for #{exp.args_length})"
        end
      end

      if exp.is_a? Prototype
        node.args.shift

        exp.arg_types.each_with_index do |expected_type, i|
          actual_type = node.args[i].resolved_type
          unless actual_type.subclass_of? expected_type
            node.raise_error "argument number #{i + 1} of C.#{exp.name} must be an #{expected_type}, not #{actual_type}"
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
          node.raise_error "undefined method #{node.name}"
        end
      end

      instance = exp.instantiate self, @scope, node
      node.resolved_block = instance.block

      node.resolved = instance
      node.resolved_type = instance.resolved_type

      if node.resolved_type == UnknownType
        node.raise_error "can't deduce the type of #{instance.name}"
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

    def end_visit_call(node)
      node.check_break_and_next_type node.resolved_type
    end

    def new_not_equals(node)
      node.name = :'=='
      node.resolved_type = nil
      not_node = Not.new node
      not_node.accept self
      return not_node
    end

    def visit_if(node)
      node.cond.accept self
      node.raise_error "if condition must be Bool" unless node.cond.resolved_type == @scope.bool_class

      node.then.accept self
      node.else.accept self
      node.resolved_type = merge_types(node, node.then.resolved_type, node.else.resolved_type)
      false
    end

    def visit_static_if(node)
      node.cond.accept self
      node.raise_error "If condition must be Bool" unless node.cond.resolved_type == @scope.bool_class
      node.raise_error "can't evaluate If at compile-time" unless node.cond.can_be_evaluated_at_compile_time?

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

    def visit_not(node)
      node.exp.accept self
      node.raise_error "! condition must be Bool" unless node.exp.resolved_type == @scope.bool_class
      node.resolved_type = @scope.bool_class
      false
    end

    def visit_and(node)
      node.left.accept self
      node.right.accept self
      node.raise_error "left && condition must be Bool" unless node.left.resolved_type == @scope.bool_class
      node.raise_error "right && condition must be Bool" unless node.right.resolved_type == @scope.bool_class
      node.resolved_type = @scope.bool_class
      false
    end

    def visit_or(node)
      node.left.accept self
      node.right.accept self
      node.raise_error "left || condition must be Bool" unless node.left.resolved_type == @scope.bool_class
      node.raise_error "right || condition must be Bool" unless node.right.resolved_type == @scope.bool_class
      node.resolved_type = @scope.bool_class
      false
    end

    def visit_yield(node)
      raise "expected to be invoked with a block" unless node.block

      node.args.each { |arg| arg.accept self }
      node.args.each_with_index { |arg, i| node.block.args[i].resolved_type = arg.resolved_type }
      node.block.accept self
      node.resolved_type = node.block.resolved_type

      args_types = node.args.map(&:resolved_type)

      node.raise_error "Expected to yield with types #{@scope.def.yield_types}, not with #{args_types}" if @scope.def.yield_types && @scope.def.yield_types != args_types
      @scope.def.yield_types = args_types

      false
    end

    def visit_block_reference(node)
      false
    end

    def visit_return(node)
      if node.exp
        node.exp.accept self
        node.resolved_type = node.exp.resolved_type
      else
        node.resolved_type = @scope.nil_class
      end
      if @scope.is_block?
        def_not_block = @scope.def_not_block
        @scope.returns! def_not_block
        node.def = def_not_block
        node.block = @scope.def
        node.context = @scope.parent.context
      end
      false
    end

    def visit_next(node)
      if node.exp
        node.exp.accept self
        node.resolved_type = node.exp.resolved_type
      else
        node.resolved_type = @scope.nil_class
      end
      false
    end

    def visit_break(node)
      if node.exp
        node.exp.accept self
        node.resolved_type = node.exp.resolved_type
      else
        node.resolved_type = @scope.nil_class
      end
      false
    end

    def merge_types(node, type1, type2)
      return type2 if type1.nil? || type1 == UnknownType || type1 == @scope.nil_class
      return type1 if type2.nil? || type2 == UnknownType || type2 == @scope.nil_class
      return type1 if type1 == type2
      node.raise_error "if branches have different types: #{type1} and #{type2}"
    end

    def with_new_scope(scope)
      old_scope = @scope
      @scope = scope
      yield
      @scope = old_scope
    end
  end
end
