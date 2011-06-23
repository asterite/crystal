require 'strscan'
require(File.expand_path("../../lib/token",  __FILE__))

class Lexer < StringScanner
  def initialize(str)
    super
    @token = Token.new
  end

  def next_token
    if eos?
      @token.type = :EOF
    elsif scan /\n/
      @token.type = :NEWLINE
    elsif scan /\s+/
      @token.type = :SPACE
    elsif match = scan(%r(;|==|=|<=|<|>=|>|\+|-|\*|/|\(|\)|,))
      @token.type = match.to_sym
    elsif match = scan(/def|else|end|if/)
      @token.type = :IDENT
      @token.value = match.to_sym
    elsif match = scan(/[a-zA-Z_][a-zA-Z_0-9]*/)
      @token.type = :IDENT
      @token.value = match
    elsif match = scan(/\d+/)
      @token.type = :INT
      @token.value = match.to_i
    else
      raise "Can't lex anymore: #{rest}"
    end

    @token
  end

  def next_token_skip_space
    next_token
    next_token if @token.type == :SPACE || @token.type == :NEWLINE
  end
end
