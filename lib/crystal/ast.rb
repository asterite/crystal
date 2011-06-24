module Crystal
  class ASTNode
  end

  class Module < ASTNode
    def accept(visitor)
      if visitor.visit_module self
        expressions.each { |exp| exp.accept visitor }
      end
      visitor.end_visit_module self
    end
  end

  class Expression < ASTNode
  end

  class Int < Expression
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def accept(visitor)
      visitor.visit_int self
      visitor.end_visit_int self
    end

    def ==(other)
      other.is_a?(Int) && other.value == value
    end
  end

  [["Add", "+"],
   ["Sub", "-"],
   ["Mul", "*"],
   ["Div", "/"],
   ["LT",  "<"],
   ["LET",  "<="],
   ["EQ",  "=="],
   ["GT",  ">"],
   ["GET",  ">="],
  ].each do |name, op|
    eval %Q(
      class #{name} < Expression
        attr_accessor :left
        attr_accessor :right

        def initialize(left, right)
          @left = left
          @right = right
        end

        def accept(visitor)
          if visitor.visit_#{name.downcase} self
            left.accept visitor
            right.accept visitor
          end
          visitor.end_visit_#{name.downcase} self
        end

        def ==(other)
          other.is_a?(#{name}) && other.left == left && other.right == right
        end
      end
    )
  end

  class Def < Expression
    attr_accessor :name
    attr_accessor :args
    attr_accessor :body

    def initialize(name, args, body)
      @name = name
      @args = args
      @body = body
    end

    def accept(visitor)
      if visitor.visit_def self
        args.each { |arg| arg.accept visitor }
        body.accept visitor if body
      end
      visitor.end_visit_def self
    end

    def ==(other)
      other.is_a?(Def) && other.name == name && other.args == args && other.body == body
    end
  end

  class Ref < Expression
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def accept(visitor)
      visitor.visit_ref self
      visitor.end_visit_ref self
    end

    def ==(other)
      other.is_a?(Ref) && other.name == name
    end
  end

  class Arg < ASTNode
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def accept(visitor)
      visitor.visit_arg self
      visitor.end_visit_arg self
    end

    def ==(other)
      other.is_a?(Arg) && other.name == name
    end
  end

  class Call < Expression
    attr_accessor :name
    attr_accessor :args

    def initialize(name, *args)
      @name = name
      @args = args
    end

    def accept(visitor)
      if visitor.visit_call self
        args.each { |arg| arg.accept visitor }
      end
      visitor.end_visit_call self
    end

    def ==(other)
      other.is_a?(Call) && other.name == name && other.args == args
    end
  end
end
