require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    attr_accessor :resolved
    attr_accessor :resolved_type

    def replace_yield(block)
      visitor = ReplaceYieldVisitor.new block
      self.accept visitor
    end

    def count_yield_args
      visitor = CountYieldArgsVisitor.new
      self.accept visitor
      visitor.count
    end
  end

  class ReplaceYieldVisitor < Visitor
    def initialize(block)
      @block = block
    end

    def visit_yield(node)
      node.block = @block
    end
  end

  class CountYieldArgsVisitor < Visitor
    attr_accessor :count

    def initialize
      @count = 0
    end

    def visit_yield(node)
      @count = node.args.length
    end
  end
end
