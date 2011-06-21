require 'test/unit'
require(File.expand_path("../../lib/lexer",  __FILE__))

describe Lexer do
  it "lexes def" do
    token = Lexer.lex('def').first
    token.type.should eq(:IDENT)
    token.value.should eq(:def)
  end
end
