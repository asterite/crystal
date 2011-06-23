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
    "def #{name}\n  #{body}\nend"
  end
end
