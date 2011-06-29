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

  class Expressions < Expression
    attr_accessor :expressions

    def self.from(obj)
      case obj
      when nil
        Expressions.new
      when Expressions
        obj
      when Array
        Expressions.new obj
      else
        Expressions.new [obj]
      end
    end

    def initialize(expressions = nil)
      @expressions = expressions || []
    end

    def accept(visitor)
      if visitor.visit_expressions self
        expressions.each { |exp| exp.accept visitor }
      end
      visitor.end_visit_expressions self
    end

    def ==(other)
      other.is_a?(Expressions) && other.expressions == expressions
    end

  end

  class Bool < Expression
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def accept(visitor)
      visitor.visit_bool self
      visitor.end_visit_bool self
    end

    def ==(other)
      other.is_a?(Bool) && other.value == value
    end
  end

  class Int < Expression
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def has_sign?
      @value[0] == '+' || @value[0] == '-'
    end

    def accept(visitor)
      visitor.visit_int self
      visitor.end_visit_int self
    end

    def ==(other)
      other.is_a?(Int) && other.value.to_i == value.to_i
    end
  end

  class Def < Expression
    attr_accessor :name
    attr_accessor :args
    attr_accessor :body

    def initialize(name, args, body)
      @name = name
      @args = args
      @body = Expressions.from body
    end

    def accept(visitor)
      if visitor.visit_def self
        args.each { |arg| arg.accept visitor }
        body.accept visitor
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

  class Var < ASTNode
    attr_accessor :name

    def initialize(name, resolved_type = nil)
      @name = name
      @resolved_type = resolved_type
    end

    def accept(visitor)
      visitor.visit_var self
      visitor.end_visit_var self
    end

    def ==(other)
      other.is_a?(Var) && other.name == name
    end

    def initialize_copy(other)
      other
    end
  end

  class Call < Expression
    attr_accessor :obj
    attr_accessor :name
    attr_accessor :args

    def initialize(obj, name, *args)
      @obj = obj
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
      other.is_a?(Call) && other.obj == obj && other.name == name && other.args == args
    end
  end

  class If < Expression
    attr_accessor :cond
    attr_accessor :then
    attr_accessor :else

    def initialize(cond, a_then, a_else = nil)
      @cond = cond
      @then = Expressions.from a_then
      @else = Expressions.from a_else
    end

    def accept(visitor)
      if visitor.visit_if self
        self.cond.accept visitor
        self.then.accept visitor
        self.else.accept visitor if self.else
      end
      visitor.end_visit_if self
    end

    def ==(other)
      other.is_a?(If) && other.cond == cond && other.then == self.then && other.else == self.else
    end
  end
end
