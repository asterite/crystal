require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    def can_be_evaluated_at_compile_time?
      visitor = CanBeEvaluatedAtCompileTimeVisitor.new
      self.accept visitor
      visitor.result
    end
  end

  class CanBeEvaluatedAtCompileTimeVisitor < Visitor
    attr_accessor :result

    def initialize
      @result = true
    end

    def visit_ref(node)
      @result = false unless node.resolved.compile_time_value
    end
  end
end
