module Crystal
  class BlockContext
    attr_accessor :scope
    attr_accessor :references
    attr_accessor :loaded_context
    attr_accessor :casted_context

    def initialize(scope)
      @scope = scope
      @references = {}
    end
  end

  class BlockReference < Expression
    attr_accessor :node
    attr_accessor :context

    def initialize(context, node)
      @context = context
      @node = node
    end

    def accept(visitor)
      visitor.visit_block_reference self
      visitor.end_visit_block_reference self
    end

    def resolved_type
      node.resolved_type
    end
  end
end
