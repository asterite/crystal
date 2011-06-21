require 'rltk/lexer'

class Lexer < RLTK::Lexer
  rule(/\s/)
  rule(/def/) { [:IDENT, :def] }
  rule(/\w+/) { |id| [:IDENT, id] }
end
