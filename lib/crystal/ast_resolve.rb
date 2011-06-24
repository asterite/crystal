require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    def resolve(mod)
      visitor = ResolveVisitor.new(mod)
      self.accept visitor
      visitor.resolved
    end
  end

  class ResolveVisitor < Visitor
    attr_accessor :resolved

    def initialize(mod)
      @mod = mod
    end

    def visit_ref(node)
      exp = @mod.find_expression node.name
      exp.resolve @mod
      @resolved = exp
    end

    def visit_def(node)
      node.codegen @mod
    end
  end
end
