class Module
end

class Expression
end

class Int < Expression
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def ==(other)
    other.is_a?(Int) && other.value == value
  end

  def to_s
    value.to_s
  end
end

[["Add", "+"],
 ["Sub", "-"],
 ["Mul", "*"],
 ["Div", "/"]
].each do |name, op|
  eval %Q(
    class #{name} < Expression
      attr_accessor :left
      attr_accessor :right

      def initialize(left, right)
        @left = left
        @right = right
      end

      def ==(other)
        other.is_a?(#{name}) && other.left == left && other.right == right
      end

      def to_s
        "\#{left} #{op} \#{right}"
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

  def ==(other)
    other.is_a?(Def) && other.name == name && other.args == args && other.body == body
  end

  def to_s
    s = "def #{name}"
    unless args.empty?
      s << "("
      i = 0
      args.each do |arg|
        s << ", " if i > 0
        s << arg.to_s
        i += 1
      end
      s << ")"
    end
    s << "\n"
    s << "  #{body}\n"
    s << "end"
    s
  end
end

class Call < Expression
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def ==(other)
    other.is_a?(Call) && other.name == name
  end

  def to_s
    name
  end
end

class Arg
  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def ==(other)
    other.is_a?(Arg) && other.name == name
  end

  def to_s
    name
  end
end
