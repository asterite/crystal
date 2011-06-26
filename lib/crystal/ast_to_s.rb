require(File.expand_path("../visitor",  __FILE__))

module Crystal
  class ASTNode
    def to_s
      visitor = ToSVisitor.new
      self.accept visitor
      visitor.to_s
    end
  end

  class Module
    def to_s
      "<Module>"
    end
  end

  class ToSVisitor < Visitor
    def initialize
      @str = ""
      @indent = 0
    end

    def visit_module(node)
    end

    def visit_int(node)
      @str << node.value.to_s
    end

    [
      ["add", "+"],
      ["sub", "-"],
      ["mul", "*"],
      ["div", "/"],
      ["lt", "<"],
      ["let", "<="],
      ["eq", "=="],
      ["gt", ">"],
      ["get", ">="],
    ].each do |node, op|
      class_eval %Q(
        def visit_#{node}(node)
          node.left.accept self
          @str << " #{op} "
          node.right.accept self
          false
        end
      )
    end

    def visit_ref(node)
      @str << node.name
      false
    end

    def visit_call(node)
      @str << node.name
      @str << "("
      node.args.each_with_index do |arg, i|
        @str << ", " if i > 0
        arg.accept self
      end
      @str << ")"
      false
    end

    def visit_def(node)
      @str << "def "
      @str << node.name
      unless node.args.empty?
        @str << "("
        node.args.each_with_index do |arg, i|
          @str << ", " if i > 0
          arg.accept self
          i += 1
        end
        @str << ")"
      end
      @str << "\n"
      @indent += 1
      node.body.accept self
      @indent -= 1
      @str << "end"
      false
    end

    def visit_var(node)
      @str << node.name
    end

    def visit_expressions(node)
      node.expressions.each do |exp|
        @str << ('  ' * @indent)
        exp.accept self
        @str << "\n"
      end
      false
    end

    def visit_if(node)
      @str << "if "
      node.cond.accept self
      @str << "\n"
      @indent += 1
      node.then.accept self
      @indent -= 1
      @str << "end"
      false
    end

    def to_s
      @str
    end
  end
end
