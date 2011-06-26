require 'strscan'

module Crystal
  class Lexer < StringScanner
    def initialize(str)
      super
      @token = Token.new
    end

    def next_token
      @token.value = nil

      if eos?
        @token.type = :EOF
      elsif scan /\n/
        @token.type = :NEWLINE
      elsif scan /\s+/
        @token.type = :SPACE
      elsif scan /;+/
        @token.type = :";"
      elsif match = scan(/(\+|-)?\d+/)
        @token.type = :INT
        @token.value = match
      elsif match = scan(%r(==|=|<=|<|>=|>|\+|-|\*|/|\(|\)|,))
        @token.type = match.to_sym
      elsif match = scan(/def|else|end|if/)
        @token.type = :IDENT
        @token.value = match.to_sym
      elsif match = scan(/[a-zA-Z_][a-zA-Z_0-9]*/)
        @token.type = :IDENT
        @token.value = match
      else
        raise "Can't lex anymore: #{rest}"
      end

      @token
    end

    def next_token_skip_space
      next_token
      skip_space
    end

    def next_token_skip_space_or_newline
      next_token
      skip_space_or_newline
    end

    def next_token_skip_statement_end
      next_token
      skip_statement_end
    end

    def skip_space
      next_token_if :SPACE
    end

    def skip_space_or_newline
      next_token_if :SPACE, :NEWLINE
    end

    def skip_statement_end
      next_token_if :SPACE, :NEWLINE, :";"
    end

    def next_token_if(*types)
      next_token while types.include? @token.type
    end
  end
end
