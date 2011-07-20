require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    attr_accessor :resolved
    attr_accessor :resolved_type

    def replace_yield(block)
      visitor = ReplaceYieldVisitor.new block
      self.accept visitor
    end
  end

  class ReplaceYieldVisitor < Visitor
    def initialize(block)
      @block = block
    end

    def visit_yield(node)
      node.parent.replace node, Call.new(nil, @block.name, node.args)
    end
  end
end
