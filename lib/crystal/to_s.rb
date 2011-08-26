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

    def visit_class(node)
      @str << node.name
    end

    def visit_nil(node)
      @str << 'nil'
    end

    def visit_bool(node)
      @str << (node.value ? 'true' : 'false')
    end

    def visit_int(node)
      @str << node.value.to_s
    end

    def visit_float(node)
      @str << node.value.to_s
    end

    def visit_long(node)
      @str << node.value.to_s
    end

    def visit_char(node)
      @str << "'"
      @str << node.value.chr
      @str << "'"
    end

    def visit_class_reference(node)
      @str << node.klass
    end

    def visit_ref(node)
      @str << node.name
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
        @str << "." if node.obj
        @str << node.name.to_s
        @str << "("
        node.args.each_with_index do |arg, i|
          @str << ", " if i > 0
          arg.accept self
        end
        @str << ")"
      end
      if node.block
        @str << " "
        node.block.accept self
      end
      false
    end

    def visit_block_call(node)
      @str << node.block.name
      @str << "("
      node.args.each_with_index do |arg, i|
        @str << ", " if i > 0
        arg.accept self
      end
      @str << ")"
      false
    end

    def visit_yield(node)
      @str << "yield"
      unless node.args.empty?
        @str << " "
        node.args.each_with_index do |arg, i|
          @str << ", " if i > 0
          arg.accept self
        end
      end
      false
    end

    def visit_block(node)
      @str << "do"
      unless node.args.empty?
        @str << " |"
        node.args.each_with_index do |arg, i|
          @str << ", " if i > 0
          arg.accept self
        end
        @str << "|\n"
      end

      with_indent do
        node.body.accept self
      end
      append_indent
      @str << "end"
      false
    end

    def visit_def(node)
      @str << "def "
      @str << node.name.to_s
      if node.args.length > 0 || node.block
        @str << "("
        node.args.each_with_index do |arg, i|
          @str << ", " if i > 0
          arg.accept self
          i += 1
        end
        if node.block
          @str << ", " unless node.args.empty?
          @str << '&'
          @str << node.block.name
        end
        @str << ")"
      end
      @str << "\n"
      with_indent { node.body.accept self } if node.body
      append_indent
      @str << "end"
      false
    end

    def visit_var(node)
      @str << node.name
    end

    def visit_expressions(node)
      node.expressions.each do |exp|
        append_indent
        exp.accept self
        @str << "\n"
      end
      false
    end

    def visit_if(node)
      @str << "if "
      node.cond.accept self
      @str << "\n"
      with_indent { node.then.accept self }
      unless node.else.expressions.empty?
        append_indent
        @str << "else\n"
        with_indent { node.else.accept self }
      end
      append_indent
      @str << "end"
      false
    end

    def visit_static_if(node)
      @str << "If "
      node.cond.accept self
      @str << "\n"
      with_indent { node.then.accept self }
      unless node.else.expressions.empty?
        append_indent
        @str << "Else\n"
        with_indent { node.else.accept self }
      end
      append_indent
      @str << "End"
      false
    end

    def visit_prototype(node)
      @str << "extern "
      @str << " "
      @str << node.name
      @str << " "
      node.arg_types.each_with_index do |type, i|
        @str << ", " if i > 0
        type.accept self
      end
      @str << " #=> "
      node.resolved_type.accept self
      false
    end

    def visit_class_def(node)
      @str << "class "
      @str << node.name
      if node.superclass
        @str << " < "
        @str << node.superclass
      end
      @str << "\n"
      with_indent { node.body.accept self }
      @str << "end"
      false
    end

    def visit_assign(node)
      node.target.accept self
      @str << " = "
      node.value.accept self
      false
    end

    def visit_while(node)
      @str << "while "
      node.cond.accept self
      @str << "\n"
      with_indent { node.body.accept self }
      append_indent
      @str << "end"
      false
    end

    def visit_not(node)
      @str << "!("
      node.exp.accept self
      @str << ")"
      false
    end

    def visit_and(node)
      node.left.accept self
      @str << " && "
      node.right.accept self
      false
    end

    def visit_or(node)
      node.left.accept self
      @str << " || "
      node.right.accept self
      false
    end

    def visit_block_reference(node)
      @str << "&"
      node.node.accept self
      false
    end

    def visit_return(node)
      @str << "return"
      if node.exp
        @str << " "
        node.exp.accept self
      end
      false
    end

    def visit_next(node)
      @str << "next"
      if node.exp
        @str << " "
        node.exp.accept self
      end
      false
    end

    def with_indent
      @indent += 1
      yield
      @indent -= 1
    end

    def append_indent
      @str << ('  ' * @indent)
    end

    def to_s
      @str
    end
  end
end
