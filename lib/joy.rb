require 'rubygems'
['lexer'].each do |filename|
  require(File.expand_path("../#{filename}",  __FILE__))
end

p Lexer.lex('def').map(&:type)
