require(File.expand_path("../../lib/ast",  __FILE__))

class Parser < Lexer
  def self.parse(str)
    new(str).parse
  end

  def initialize(str)
    super
    next_token_skip_space
  end

  def parse
    parse_expressions
  end

  def parse_expressions
    exps = []
    while @token.type != :EOF
      exps << parse_expression
      next_token if @token.type == :SPACE || @token.type == :NEWLINE
    end
    exps
  end

  def parse_expression
    parse_add_or_sub
  end

  def parse_add_or_sub
    left = parse_mul_or_div
    while true
      case @token.type
      when :SPACE
        next_token
      when :"+"
        next_token_skip_space
        right = parse_mul_or_div
        left = Add.new left, right
      else
        return left
      end
    end

  end

  def parse_mul_or_div
    parse_atomic
  end

  def parse_atomic
    case @token.type
    when :"+"
      next_token_skip_space
      check :INT
      node_and_next_token Int.new(@token.value)
    when :"-"
      next_token_skip_space
      check :INT
      node_and_next_token Int.new(-@token.value)
    when :INT
      node_and_next_token Int.new(@token.value)
    end
  end

  def node_and_next_token(node)
    next_token
    node
  end

  private

  def check(*token_types)
    raise "Expecting token #{token_types}" unless token_types.any?{|type| @token.type == type}
  end
end
