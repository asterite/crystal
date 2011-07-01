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

    def visit_bool(node)
      @str << (node.value ? 'true' : 'false')
      append_resolved_type node
    end

    def visit_int(node)
      @str << node.value.to_s
      append_resolved_type node
    end

    def visit_class_reference(node)
      @str << node.klass
    end

    def visit_ref(node)
      @str << node.name
      append_resolved_type node
      false
    end

    def visit_call(node)
      node.obj.accept self if node.obj
      if node.obj && node.name.is_a?(Symbol) && node.args.length == 1
        @str << " "
        @str << node.name.to_s
        @str << " "
        node.args[0].accept self
      else
        @str << node.name.to_s
        @str << "("
        node.args.each_with_index do |arg, i|
          @str << ", " if i > 0
          arg.accept self
        end
        @str << ")"
      end
      append_resolved_type node
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
      node.body.accept self if node.body
      @indent -= 1
      @str << "end"
      append_resolved_type node
      false
    end

    def visit_var(node)
      @str << node.name
      append_resolved_type node
    end

    def visit_expressions(node)
      node.expressions.each do |exp|
        @str << ('  ' * @indent)
        exp.accept self
        @str << "\n"
      end
      append_resolved_type node
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
      append_resolved_type node
      false
    end

    def append_resolved_type(node)
      @str << "{#{node.resolved_type}}" if node.resolved_type
    end

    def to_s
      @str
    end
  end
end
