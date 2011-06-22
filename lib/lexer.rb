require 'rltk/lexer'

class Lexer < RLTK::Lexer
  rule(/\s/)

  rule(/def/) { [:IDENT, :def] }
  rule(/if/) { [:IDENT, :if] }
  rule(/else/) { [:IDENT, :else] }
  rule(/end/) { [:IDENT, :end] }

  rule(/\d+/) { |num| [:INT, num.to_i] }
  rule(/[a-zA-Z_][a-zA-Z_0-9]*/) { |id| [:IDENT, id] }
  rule(/=/) { :EQ }
  rule(/</) { :LT }
  rule(/<=/) { :LET }
  rule(/>/) { :GT }
  rule(/>=/) { :GET }
  rule(/\+/) { :PLUS }
  rule(/\-/) { :MINUS }
  rule(/\*/) { :STAR }
  rule(/\//) { :SLASH }
  rule(/\(/) { :LPAREN }
  rule(/\)/) { :RPAREN }
  rule(/==/) { :COMP }
  rule(/,/) { :COMMA }
end
