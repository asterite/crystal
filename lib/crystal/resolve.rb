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
      node.resolved_type = node.metaclass
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

    def visit_extern(node)
      node.arg_types.map! do |arg_type|
        @scope.find_class arg_type.name or node.raise_error "undefined class #{arg_type}"
      end
      node.resolved_type = @scope.find_class(node.resolved_type.name) or node.raise_error "undefined class #{node.resolved_type}"
    end

    def visit_def(node)
      return false if node.resolved_type

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
      exp = @scope.find_class node.name
      unless exp
        if node.superclass
          superclass = @scope.find_class(node.superclass) or node.raise_error "undefined class '#{node.superclass}'"
        else
          superclass = @scope.object_class
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

      exp = @scope.find_local_var node.name
      if exp
        exp.accept self
      else
        exp = @scope.find_class node.name
        if exp
          exp.accept self
        else
          exp = @scope.find_method(node.name) or node.raise_error "undefined local variable or method '#{node.name}'"
          target = exp.is_a?(Def) && exp.obj ? Ref.new('self') : nil
          call = Call.new(target, exp.name)
          call.accept self
          exp = call.resolved
        end
      end

      node.resolved = exp
      node.resolved_type = exp.resolved_type

      false
    end

    def visit_assign(node)
      node.value.accept self

      node.target.resolved = @scope.find_local_var(node.target.name)

      if node.target.resolved
        if node.value.resolved_type != UnknownType && node.target.resolved.resolved_type != node.value.resolved_type
          node.raise_error "can't assign #{node.value.resolved_type} to #{node.target} of type #{node.target.resolved.resolved_type}"
        end
      else
        var = Var.new(node.target.name, node.value.resolved_type)

        @scope.define_local_var var
        node.target.resolved = var
      end

      node.resolved_type = node.value.resolved_type

      false
    end

    def visit_call(node)
      return if node.resolved_type

      node.resolved_type = UnknownType
      node.block.scope = @scope if node.block

      if node.obj
        node.obj.accept self

        # Solve class method at compile-time
        if node.obj && node.name == :class && node.args.empty?
          node.parent.replace node, node.obj.resolved_type
          return false
        end

        method = node.obj.resolved_type.find_method(node.name)

        unless method
          # Special case: rewrite a != b as !(a == b)
          return rewrite_not_equals node if node.name == :'!='

          node.raise_error "undefined method '#{node.name}' for #{node.obj.resolved_type}" unless method
        end
      else
        method = @scope.find_method(node.name)

        unless method
          # Check if it's foo -1, which is parsed as a call "foo(-1)" but can be understood as "foo - 1"
          if node.args_length == 1 && node.args[0].is_a?(Int) && node.args[0].has_sign?
            exp = @scope.find_local_var node.name
            if exp
              node.resolved = exp
              node.resolved_type = exp.resolved_type
              return false
            end
          end

          # Check if it's a class template
          klass = @scope.find_class node.name
          if klass
            if node.args_length != klass.args_length
              node.raise_error "wrong number of arguments (#{node.args_length} for #{klass.args_length})"
            end

            node.args.each_with_index do |arg, i|
              arg.accept self

              if arg.resolved_type.class != Metaclass
                node.raise_error "expected argument #{i + 1} of #{node.name}(...) to be a Class, not #{arg.resolved_type}"
              end
            end

            instance = klass.instantiate self, @scope, node.args.map(&:resolved_type).map(&:real_class)
            node.parent.replace node, instance
            return false
          end

          node.raise_error "undefined method '#{node.name}'"
        end
      end

      if node.args_length != method.args_length
        node.raise_error "wrong number of arguments (#{node.args_length} for #{method.args_length})"
      end

      node.args.each { |arg| arg.accept self }

      if method.is_a? Extern
        method.arg_types.each_with_index do |expected_type, i|
          actual_type = node.args[i].resolved_type
          unless actual_type.subclass_of? expected_type
            node.raise_error "argument number #{i + 1} of C.#{method.name} must be an #{expected_type}, not #{actual_type}"
          end
        end

        node.resolved = method
        node.resolved_type = method.resolved_type
        return false
      elsif !node.obj && method.obj
        node.obj = Ref.new 'self'
        node.obj.accept self
      end

      instance = method.instantiate self, @scope, node

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

      false
    end

    def rewrite_not_equals(node)
      node.name = :'=='
      node.resolved_type = nil

      parent = node.parent

      not_node = Not.new node
      not_node.accept self

      parent.replace node, not_node

      false
    end

    def end_visit_call(node)
      node.check_break_and_next_type node.resolved_type
    end

    def visit_if(node)
      node.cond.accept self
      node.raise_error "if condition must be Bool, not #{node.cond.resolved_type}" unless node.cond.resolved_type == @scope.bool_class

      node.then.accept self
      node.else.accept self
      node.resolved_type = merge_types(node, node.then.resolved_type, node.else.resolved_type)
      false
    end

    def visit_static_if(node)
      node.cond.accept self
      node.raise_error "If condition must be Bool, not #{node.cond.resolved_type}" unless node.cond.resolved_type == @scope.bool_class
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
      node.resolved_type = @scope.nil_class
      false
    end

    def visit_not(node)
      node.exp.accept self
      node.raise_error "! condition must be Bool, not #{node.exp.resolved_type}" unless node.exp.resolved_type == @scope.bool_class
      node.resolved_type = @scope.bool_class
      false
    end

    def visit_and(node)
      node.left.accept self
      node.right.accept self
      node.raise_error "left && condition must be Bool, not #{node.left.resolved_type}" unless node.left.resolved_type == @scope.bool_class
      node.raise_error "right && condition must be Bool, not #{node.left.resolved_type}" unless node.right.resolved_type == @scope.bool_class
      node.resolved_type = @scope.bool_class
      false
    end

    def visit_or(node)
      node.left.accept self
      node.right.accept self
      node.raise_error "left || condition must be Bool, not #{node.left.resolved_type}" unless node.left.resolved_type == @scope.bool_class
      node.raise_error "right || condition must be Bool, not #{node.right.resolved_type}" unless node.right.resolved_type == @scope.bool_class
      node.resolved_type = @scope.bool_class
      false
    end

    def visit_yield(node)
      node.raise_error "expected to be invoked with a block" unless node.block

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

    def visit_new_static_array(node)
      node.resolved_type = @scope.def.obj.real_class
      false
    end

    def visit_static_array_set(node)
      node.resolved_type = @scope.def.obj.args[0].resolved_type
      false
    end

    def visit_static_array_get(node)
      node.resolved_type = @scope.def.obj.args[0].resolved_type
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
