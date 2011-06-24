require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    def eval(mod)
      visitor = EvalVisitor.new mod
      self.accept visitor
      visitor.value
    end
  end

  class Module
    def define(*nodes)
      value = nil
      nodes.each do |node|
        value = node.eval self
      end
      value
    end

    def eval(string)
      nodes = Parser.parse string
      return nil if nodes.empty?

      define *nodes
    end
  end

  class EvalVisitor < Visitor
    attr_reader :value

    def initialize(mod)
      @mod = mod
    end

    ['int', 'add', 'sub', 'mul', 'div'].each do |node|
      class_eval %Q(
        def visit_#{node}(node)
          anon_def = Def.new "", [], node
          fun = anon_def.codegen @mod
          @value = @mod.run fun
          false
        end
      )
    end

    def visit_def(node)
      @mod.add_expression node
      false
    end

    def visit_ref(node)
      resolved = node.resolve @mod
      @value = @mod.run resolved.code
    end
  end
end
