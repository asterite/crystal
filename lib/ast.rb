class Expression
end

class Int < Expression
  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def to_s
    value.to_s
  end
end

class Add < Expression
  attr_accessor :left
  attr_accessor :right

  def initialize(left, right)
    @left = left
    @right = right
  end

  def to_s
    "#{left} + #{right}"
  end
end
