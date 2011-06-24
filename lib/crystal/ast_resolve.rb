require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    def resolve(mod)
      visitor = ResolveVisitor.new mod
      self.accept visitor
    end
  end

  class Ref
    attr_accessor :resolved
  end

  class Call
    attr_accessor :resolved
  end

  class ResolveVisitor < Visitor
    attr_accessor :resolved

    def initialize(mod)
      @mod = mod
    end

    def visit_int(node)
    end

    ['add', 'sub', 'mul', 'div'].each do |node|
      class_eval %Q(
        def visit_#{node}(node)
          node.left.resolve @mod
          node.right.resolve @mod
          false
        end
      )
    end

    def visit_def(node)
      @mod.add_expression node
      node.body.resolve DefScope.new(@mod, node)
    end

    def visit_ref(node)
      exp = @mod.find_expression(node.name) or raise "Error: undefined local variable or method '#{node.name}'"
      exp.resolve @mod

      node.resolved = exp
    end

    def visit_call(node)
      exp = @mod.find_expression(node.name) or raise "Error: undefined method '#{node.name}'"

      if node.args.length != exp.args.length
        raise "Error: wrong number of arguments (#{node.args.length} for #{exp.args.length})"
      end

      exp.resolve @mod

      node.resolved = exp
    end
  end

  class DefScope
    def initialize(mod, a_def)
      @mod = mod
      @def = a_def
    end

    def add_expression(node)
      @mod.add_expression node
    end

    def find_expression(name)
      arg = @def.args.select{|arg| arg.name == name}.first
      return arg if arg

      @mod.find_expression name
    end

    def module
      @mod.module
    end

    def builder
      @mod.builder
    end
  end
end
