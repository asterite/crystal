module Crystal
  class Parser < Lexer
    def self.parse(str)
      new(str).parse
    end

    def initialize(str)
      super
      next_token_skip_statement_end
    end

    def parse
      parse_expressions
    end

    def parse_expressions
      exps = []
      while @token.type != :EOF && !(@token.type == :IDENT && (@token.value == :end || @token.value == :else))
        exps << parse_expression
        skip_statement_end
      end
      Expressions.new exps
    end

    def parse_expression
      if @token.type == :IDENT
        case @token.value
        when :def
          return parse_def
        when :if
          return parse_if
        when :extern
          return parse_extern
        end
      end

      parse_primary_expression
    end

    def parse_def
      next_token_skip_space_or_newline
      check :IDENT

      name = @token.value
      args = []

      next_token_skip_space

      case @token.type
      when :'('
        next_token_skip_space_or_newline
        while @token.type != :')'
          check_ident
          args << Var.new(@token.value)
          next_token_skip_space_or_newline
          if @token.type == :','
            next_token_skip_space_or_newline
          end
        end
        next_token_skip_statement_end
      when :IDENT
        while @token.type != :NEWLINE && @token.type != :";"
          check_ident
          args << Var.new(@token.value)
          next_token_skip_space
          if @token.type == :','
            next_token_skip_space_or_newline
          end
        end
        next_token_skip_statement_end
      else
        skip_statement_end
      end

      if @token.type == :IDENT && @token.value == :end
        body = nil
      else
        body = parse_expressions
        skip_statement_end
        check_ident :end
      end

      next_token_skip_statement_end
      Def.new name, args, body
    end

    def parse_if
      next_token_skip_space_or_newline

      cond = parse_expression
      skip_statement_end

      a_then = parse_expressions
      skip_statement_end

      a_else = if @token.type == :IDENT && @token.value == :else
                 next_token_skip_statement_end
                 parse_expressions
               else
                 nil
               end

      check_ident :end
      next_token_skip_statement_end

      If.new cond, a_then, a_else
    end

    def parse_extern
      next_token_skip_space_or_newline
      check :IDENT
      name = @token.value
      next_token
      args_types = parse_args
      check :'#=>'
      next_token_skip_space
      return_type = parse_expression
      Prototype.new name, (args_types || []), return_type
    end

    def parse_primary_expression
      left = parse_add_or_sub
      while true
        case @token.type
        when :SPACE
          next_token
        when :"<", :"<=", :"==", :">", :">="
          method = @token.type

          next_token_skip_space_or_newline
          right = parse_add_or_sub
          left = Call.new left, method, right
        else
          return left
        end
      end
    end

    def parse_add_or_sub
      left = parse_mul_or_div
      while true
        case @token.type
        when :SPACE
          next_token
        when :"+", :"-"
          method = @token.type
          next_token_skip_space_or_newline
          right = parse_mul_or_div
          left = Call.new left, method, right
        when :INT
          case @token.value[0]
          when '+', '-'
            left = Call.new left, @token.value[0].to_sym, Int.new(@token.value)
            next_token_skip_space_or_newline
          else
            return left
          end
        else
          return left
        end
      end

    end

    def parse_mul_or_div
      left = parse_atomic_with_method
      while true
        case @token.type
        when :SPACE
          next_token
        when :"*", :"/"
          method = @token.type
          next_token_skip_space_or_newline
          right = parse_atomic_with_method
          left = Call.new left, method, right
        else
          return left
        end
      end
    end

    def parse_atomic_with_method
      atomic = parse_atomic

      while true
        case @token.type
        when :SPACE
          next_token
        when :'.'
          next_token_skip_space_or_newline
          check :IDENT, :"+", :"-", :"*", :"/", :"<", :"<=", :"==", :">", :">="
          name = @token.type == :IDENT ? @token.value : @token.type
          next_token

          args = parse_args
          atomic = args ? (Call.new atomic, name, *args) : (Call.new atomic, name)
        else
          return atomic
        end
      end
    end

    def parse_atomic
      case @token.type
      when :'('
        next_token_skip_space_or_newline
        exp = parse_expression
        check :')'
        next_token_skip_statement_end
        exp
      when :"+"
        next_token_skip_space_or_newline
        Call.new parse_expression, :"+@"
      when :"-"
        next_token_skip_space_or_newline
        Call.new parse_expression, :"-@"
      when :INT
        node_and_next_token Int.new(@token.value)
      when :IDENT
        case @token.value
        when :false
          node_and_next_token Bool.new(false)
        when :true
          node_and_next_token Bool.new(true)
        else
          parse_ref_or_call
        end
      else
        raise "Unexpected token: #{@token.to_s}"
      end
    end

    def parse_ref_or_call
      name = @token.value
      next_token

      args = parse_args
      args ? Call.new(nil, name, *args) : Ref.new(name)
    end

    def parse_args
      case @token.type
      when :"("
        args = []
        next_token_skip_space
        while @token.type != :")"
          args << parse_expression
          skip_space
          if @token.type == :","
            next_token_skip_space_or_newline
          end
        end
        next_token_skip_space
        args
      when :SPACE
        next_token
        case @token.type
        when :NEWLINE, :";", :"+", :"-", :"*", :"/", :"<", :"<=", :"==", :">", :">=", :'#=>'
          nil
        else
          args = []
          while @token.type != :NEWLINE && @token.type != :";" && @token.type != :EOF && @token.type != :')' && @token.type != :'#=>'
            args << parse_expression
            skip_space
            if @token.type == :","
              next_token_skip_space_or_newline
            end
          end
          next_token_skip_space unless @token.type == :')' || @token.type == :'#=>'
          args
        end
      else
        nil
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

    def check_ident(value = nil)
      if value
        raise "Expecting token: #{value}" unless @token.type == :IDENT && @token.value == value
      else
        raise "Unexpected token: #{@token.to_s}" unless @token.type == :IDENT && @token.value.is_a?(String)
      end
    end
  end
end
