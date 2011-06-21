require 'test/unit'
require(File.expand_path("../../lib/lexer",  __FILE__))

describe Lexer do
  def self.it_lexes(string, type, value = nil)
    it "lexes #{string}" do
      token = Lexer.lex(string).first
      token.type.should eq(type)
      token.value.should eq(value)
    end
  end

  it_lexes "def", :IDENT, :def
end
