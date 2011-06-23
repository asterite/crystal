require(File.expand_path("../../lib/ast",  __FILE__))
require(File.expand_path("../../lib/lexer",  __FILE__))

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
      next_token if @token.type == :SPACE || @token.type == :NEWLINE || @token.type == :";"
    end
    exps
  end

  def parse_expression
    case @token.type
    when :IDENT
      case @token.value
      when :def
        return parse_def
      end
    else
      return parse_add_or_sub
    end
  end

  def parse_def
    next_token_skip_space
    check :IDENT
    name = @token.value
    next_token_skip_statement_end
    body = parse_expression
    skip_statement_end
    check_ident :end
    next_token_skip_space
    Def.new name, [], body
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
      when :"-"
        next_token_skip_space
        right = parse_mul_or_div
        left = Sub.new left, right
      else
        return left
      end
    end

  end

  def parse_mul_or_div
    left = parse_atomic
    while true
      case @token.type
      when :SPACE
        next_token
      when :"*"
        next_token_skip_space
        right = parse_atomic
        left = Mul.new left, right
      when :"/"
        next_token_skip_space
        right = parse_atomic
        left = Div.new left, right
      else
        return left
      end
    end
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
    else
      raise "Unexpected token: #{@token.type}"
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

  def check_ident(value)
    raise "Expecting token #{value}" unless @token.type == :IDENT && @token.value == value
  end
end
