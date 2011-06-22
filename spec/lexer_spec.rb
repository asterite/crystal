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

  def self.it_lexes_idents(*args)
    args.each do |arg|
      it_lexes arg, :IDENT, arg
    end
  end

  def self.it_lexes_ints(*args)
    args.each do |arg|
      it_lexes arg, :INT, arg.to_i
    end
  end

  it_lexes "def", :IDENT, :def
  it_lexes_idents "ident", "something", "with_underscores", "with_1"
  it_lexes_ints "1", "1hello"
end
