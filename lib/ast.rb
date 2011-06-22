require 'rltk/ast'

class Expression < RLTK::ASTNode
end

class Int < Expression
  value :value, Integer

  def to_s
    value.to_s
  end
end
