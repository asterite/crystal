require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    attr_accessor :resolved
    attr_accessor :resolved_type

    def replace_yield(a_def, block)
      visitor = ReplaceYieldVisitor.new a_def, block
      self.accept visitor
    end

    def count_yield_args
      visitor = CountYieldArgsVisitor.new
      self.accept visitor
      visitor.count
    end

    def check_break_and_next_type(type)
      self.accept CheckBreakAndNextType.new(type)
    end

    def check_return_type(type)
      self.accept CheckReturnType.new(type)
    end
  end

  class ReplaceYieldVisitor < Visitor
    def initialize(a_def, block)
      @def = a_def
      @block = block
    end

    def visit_yield(node)
      node.def = @def
      node.block = @block
      true
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

  class CheckBreakAndNextType < Visitor
    def initialize(type)
      @type = type
    end

    def visit_break(node)
      node.raise_error "Can't break with type #{node.resolved_type}, must break with #{@type}" if node.exp && node.resolved_type != @type
      true
    end

    def visit_next(node)
      node.raise_error "Can't next with type #{node.resolved_type}, must next with #{@type}" if node.exp && node.resolved_type != @type
      true
    end
  end

  class CheckReturnType < Visitor
    def initialize(type)
      @type = type
    end

    def visit_return(node)
      node.raise_error "Can't return with type #{node.resolved_type}, must return with #{@type}" if node.exp && node.resolved_type != @type
      true
    end
  end
end
