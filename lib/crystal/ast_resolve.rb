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

  class ResolveVisitor < Visitor
    attr_accessor :resolved

    def initialize(scope)
      @scope = scope
    end

    def visit_int(node)
      node.resolved = self
      node.resolved_type = Int
    end

    def visit_def(node)
      @scope.add_expression node

      with_new_scope DefScope.new(@scope, node) do
        node.body.accept self
      end
      false
    end

    def visit_ref(node)
      return if node.resolved

      exp = @scope.find_expression(node.name) or raise "Error: undefined local variable or method '#{node.name}'"
      if exp.is_a?(Def) && exp.args.length > 0
        raise "Error: wrong number of arguments (0 for #{exp.args.length})"
      end

      node.resolved = exp
      exp.accept self
    end

    def visit_call(node)
      return if node.resolved

      if node.obj
        node.obj.accept self

        resolved_type = Int # node.obj.resolved_type

        exp = @scope.find_expression "#{resolved_type}##{node.name}"
        if !exp
          exp = resolved_type.find_method(node.name) or raise "Error: undefined method '#{node.name}' for #{resolved_type}"
          @scope.add_expression exp
        end

        node.args = [node.obj] + node.args
        node.name = exp.name
        node.obj = nil
        node.accept self
        false
      else
        exp = @scope.find_expression(node.name) or raise "Error: undefined method '#{node.name}'"
        if exp.is_a? Var
          # Maybe it's foo -1, which is parsed as a call "foo(-1)" but can be understood as "foo - 1"
          if node.args.length == 1 && node.args[0].is_a?(Int) && node.args[0].has_sign?
            node.resolved = exp
            return false
          else
            raise "Error: undefined method #{node.name}"
          end
        end

        if node.args.length != exp.args.length
          raise "Error: wrong number of arguments (#{node.args.length} for #{exp.args.length})"
        end

        node.args.each { |arg| arg.accept self }
        node.resolved = exp
        exp.accept self
        false
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
