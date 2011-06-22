require 'rltk/lexer'

class Lexer < RLTK::Lexer
  rule(/\s/)
  rule(/def/) { [:IDENT, :def] }
  rule(/\d+/) { |num| [:INT, num.to_i] }
  rule(/[a-zA-Z_][a-zA-Z_0-9]*/) { |id| [:IDENT, id] }
end
