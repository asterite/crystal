require(File.expand_path("../../lib/crystal",  __FILE__))

include Crystal

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

  def self.it_lexes_keywords(*args)
    args.each do |arg|
      it_lexes arg, :IDENT, arg.to_sym
    end
  end

  def self.it_lexes_ints(*args)
    args.each do |arg|
      if arg.is_a? Array
        it_lexes arg[0], :INT, arg[1]
      else
        it_lexes arg, :INT, arg
      end
    end
  end

  it_lexes " ", :SPACE
  it_lexes "\n", :NEWLINE
  it_lexes "\n\n\n", :NEWLINE
  it_lexes_keywords "def", "if", "else", "end", "true"
  it_lexes_idents "ident", "something", "with_underscores", "with_1"
  it_lexes_ints "1", ["1hello", "1"], "+1", "-1"

  it_lexes_operators "=", "<", "<=", ">", ">=", "+", "-", "*", "/", "(", ")", "==", ",", '.'
end
