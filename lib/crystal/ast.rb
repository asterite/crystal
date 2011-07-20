module Crystal
  class ASTNode
    attr_accessor :line_number
    attr_accessor :parent
    attr_accessor :compile_time_value
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
      @expressions.each { |e| e.parent = self }
    end

    def accept(visitor)
      if visitor.visit_expressions self
        expressions.each { |exp| exp.accept visitor }
      end
      visitor.end_visit_expressions self
    end

    def replace(node, replacement)
      @expressions.each_with_index do |e, i|
        return @expressions[i] = replacement if e.equal? node
      end
    end

    def ==(other)
      other.is_a?(Expressions) && other.expressions == expressions
    end

    def clone
      exps = Expressions.new expressions.map(&:clone)
      exps.line_number = line_number
      exps
    end
  end

  class ClassDef < Expression
    attr_accessor :name
    attr_accessor :body

    def initialize(name, body = nil)
      @name = name
      @body = Expressions.from body
    end

    def accept(visitor)
      visitor.visit_class_def self
      visitor.end_visit_class_def self
    end

    def ==(other)
      other.is_a?(ClassDef) && other.name == name && other.body == body
    end

    def clone
      class_def = ClassDef.new name, body.clone
      class_def.line_number = line_number
      class_def
    end
  end

  class Class < Expression
    attr_accessor :name
    attr_accessor :type

    def initialize(name, superclass = nil, type = nil)
      @name = name
      @superclass = superclass
      @type = type
      @methods = {}
    end

    def compile_time_value
      self
    end

    def subclass_of?(other)
      self == other || @superclass == other
    end

    def find_method(name)
      method = @methods[name]
      if method
        method.dup
      else
        @superclass ? @superclass.find_method(name) : nil
      end
    end

    def define_method(name, method)
      @methods[name] = method
    end

    def define_static_method(name, method)
      unless @type
        @type = Class.new("Class", nil, self)
        @type.define_method name, method
      end
    end

    def accept(visitor)
      visitor.visit_class self
      visitor.end_visit_class self
    end

    def ==(other)
      other.is_a?(Class) && other.name == name
    end

    def to_s
      @name
    end
  end

  class Nil < Expression
    def accept(visitor)
      visitor.visit_nil self
      visitor.end_visit_nil self
    end

    def compile_time_value
      self
    end

    def ==(other)
      other.is_a?(Nil)
    end
  end

  class Bool < Expression
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def compile_time_value
      self
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

    def compile_time_value
      self
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

  class Long < Expression
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def compile_time_value
      self
    end

    def has_sign?
      @value[0] == '+' || @value[0] == '-'
    end

    def accept(visitor)
      visitor.visit_int self
      visitor.end_visit_int self
    end

    def ==(other)
      other.is_a?(Long) && other.value.to_i == value.to_i
    end
  end

  class Float < Expression
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def compile_time_value
      self
    end

    def has_sign?
      @value[0] == '+' || @value[0] == '-'
    end

    def accept(visitor)
      visitor.visit_float self
      visitor.end_visit_float self
    end

    def ==(other)
      other.is_a?(Float) && other.value.to_f == value.to_f
    end
  end

  class Char < Expression
    attr_accessor :value

    def initialize(value)
      @value = value
    end

    def compile_time_value
      self
    end

    def accept(visitor)
      visitor.visit_char self
      visitor.end_visit_char self
    end

    def ==(other)
      other.is_a?(Char) && other.value.to_i == value.to_i
    end
  end

  class Prototype < Expression
    attr_accessor :name
    attr_accessor :arg_types

    def initialize(name, arg_types, resolved_type)
      @name = name
      @arg_types = arg_types
      @resolved_type = resolved_type
    end

    def accept(visitor)
      if visitor.visit_prototype self
        arg_types.each { |type| type.accept visitor }
        resolved_type.accept visitor
      end
      visitor.end_visit_prototype self
    end

    def ==(other)
      other.is_a?(Prototype) && other.name == name && other.arg_types == arg_types && other.resolved_type == resolved_type
    end
  end

  class Def < Expression
    attr_accessor :name
    attr_accessor :args
    attr_accessor :body
    attr_accessor :block_args_types
    attr_accessor :needs_instance

    def initialize(name, args, body)
      @name = name
      @args = args
      @body = Expressions.from body
      @needs_instance = true
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

    def clone
      a_def = Def.new name, args.clone, body.clone
      a_def.line_number = line_number
      a_def
    end

    def replace_yields(block)
      @body.expressions.each do |exp|
        if exp.is_a? Yield
          call = Call.new(nil, block.name, exp.args)
          @body.replace exp, call
        end
      end
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

    def clone
      ref = Ref.new name
      ref.line_number = line_number
      ref
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

    def clone
      var = Var.new name, resolved_type
      var.line_number = line_number
      var
    end
  end

  class Call < Expression
    attr_accessor :obj
    attr_accessor :name
    attr_accessor :args
    attr_accessor :block

    def initialize(obj, name, args = [], block = nil)
      @obj = obj
      @obj.parent = self if @obj
      @name = name
      @args = args || []
      @args.each { |arg| arg.parent = self }
      @block = block
    end

    def accept(visitor)
      if visitor.visit_call self
        args.each { |arg| arg.accept visitor }
        block.accept visitor if block
      end
      visitor.end_visit_call self
    end

    def ==(other)
      other.is_a?(Call) && other.obj == obj && other.name == name && other.args == args && other.block == block
    end

    def clone
      call = Call.new obj ? obj.clone : nil, name, args.map(&:clone), block ? block.clone : nil
      call.line_number = line_number
      call
    end

    def replace(node, replacement)
      return @obj = replacement if obj.equal? node

      @args.each_with_index do |arg, i|
        return @args[i] = replacement if arg.equal? node
      end
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

    def clone
      a_if = If.new cond.clone, self.then.clone, self.else.clone
      a_if.line_number = line_number
      a_if
    end
  end

  class StaticIf < Expression
    attr_accessor :cond
    attr_accessor :then
    attr_accessor :else

    def initialize(cond, a_then, a_else = nil)
      @cond = cond
      @then = Expressions.from a_then
      @else = Expressions.from a_else
    end

    def accept(visitor)
      if visitor.visit_static_if self
        self.cond.accept visitor
        self.then.accept visitor
        self.else.accept visitor if self.else
      end
      visitor.end_visit_static_if self
    end

    def ==(other)
      other.is_a?(StaticIf) && other.cond == cond && other.then == self.then && other.else == self.else
    end

    def clone
      a_if = StaticIf.new cond.clone, self.then.clone, self.else.clone
      a_if.line_number = line_number
      a_if
    end
  end

  class Assign < Expression
    attr_accessor :target
    attr_accessor :value

    def initialize(target, value)
      @target = target
      @value = value
    end

    def accept(visitor)
      if visitor.visit_assign self
        target.accept visitor
        value.accept visitor
      end
      visitor.end_visit_assign self
    end

    def ==(other)
      other.is_a?(Assign) && other.target == target && other.value == value
    end

    def clone
      assign = Assign.new target.clone, value.clone
      assign.line_number = line_number
      assign
    end
  end

  class While < Expression
    attr_accessor :cond
    attr_accessor :body

    def initialize(cond, body = nil)
      @cond = cond
      @body = Expressions.from body
    end

    def accept(visitor)
      if visitor.visit_while self
        cond.accept visitor
        body.accept visitor
      end
      visitor.end_visit_while self
    end

    def ==(other)
      other.is_a?(While) && other.cond == cond && other.body == body
    end

    def clone
      a_while = While.new cond.clone, body.clone
      a_while.line_number = line_number
      a_while
    end
  end

  class And < Expression
    attr_accessor :left
    attr_accessor :right

    def initialize(left, right)
      @left = left
      @right = right
    end

    def accept(visitor)
      if visitor.visit_and self
        left.accept visitor
        right.accept visitor
      end
      visitor.end_visit_and self
    end

    def ==(other)
      other.is_a?(And) && other.left == left && other.right == right
    end

    def clone
      a_and = And.new left.clone, right.clone
      a_and.line_number = line_number
      a_and
    end
  end

  class Or < Expression
    attr_accessor :left
    attr_accessor :right

    def initialize(left, right)
      @left = left
      @right = right
    end

    def accept(visitor)
      if visitor.visit_and self
        left.accept visitor
        right.accept visitor
      end
      visitor.end_visit_and self
    end

    def ==(other)
      other.is_a?(Or) && other.left == left && other.right == right
    end

    def clone
      a_or = Or.new left.clone, right.clone
      a_or.line_number = line_number
      a_or
    end
  end

  class Block
    attr_accessor :args
    attr_accessor :body

    def initialize(args, body)
      @args = args
      @body = Expressions.from body
    end

    def accept(visitor)
      if visitor.visit_block self
        args.each { |arg| arg.accept visitor }
        body.accept visitor
      end
      visitor.end_visit_block self
    end

    def ==(other)
      other.is_a?(Block) && other.args == args && other.body == body
    end

    def clone
      block = Block.new args.map(&:clone), body.clone
      block.line_number = line_number
      block
    end
  end

  class Yield < Expression
    attr_accessor :args

    def initialize(args)
      @args = args
    end

    def accept(visitor)
      if visitor.visit_yield self
        args.each { |arg| arg.accept visitor }
      end
      visitor.end_visit_yield self
    end

    def ==(other)
      other.is_a?(Yield) && other.args == args
    end

    def clone
      call = Yield.new args.map(&:clone)
      call.line_number = line_number
      call
    end
  end
end
