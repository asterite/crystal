require(File.expand_path("../../lib/crystal",  __FILE__))

describe Lexer do
  def self.it_lexes(string, type, value = nil)
    it "lexes #{string}" do
      lexer = Lexer.new(string)
      token = lexer.next_token
      token.type.should eq(type)
      token.value.should eq(value)
    end
  end

  def self.it_lexes_operators(*args)
    args.each do |arg|
      it_lexes arg, arg.to_sym
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

  it_lexes " ", :SPACE
  it_lexes "\n", :NEWLINE
  it_lexes "\n\n\n", :NEWLINE
  it_lexes "def", :IDENT, :def
  it_lexes "if", :IDENT, :if
  it_lexes "else", :IDENT, :else
  it_lexes "end", :IDENT, :end
  it_lexes_idents "ident", "something", "with_underscores", "with_1"
  it_lexes_ints "1", "1hello"

  it_lexes_operators "=", "<", "<=", ">", ">=", "+", "-", "*", "/", "(", ")", "==", ","
end
