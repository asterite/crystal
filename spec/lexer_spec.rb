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

  def self.it_lexes_floats(*args)
    args.each do |arg|
      if arg.is_a? Array
        it_lexes arg[0], :FLOAT, arg[1]
      else
        it_lexes arg, :FLOAT, arg
      end
    end
  end

  def self.it_lexes_char(string, value)
    it_lexes string, :CHAR, value
  end

  it_lexes " ", :SPACE
  it_lexes "\n", :NEWLINE
  it_lexes "\n\n\n", :NEWLINE
  it_lexes_keywords "def", "if", "If", "else", "Else", "elsif", "Elsif", "end", "End", "true", "false", "extern", "class", "while", "nil", "do", "yield", "return", "unless", "Unless"
  it_lexes_idents "ident", "something", "with_underscores", "with_1", "foo?", "bar!"
  it_lexes_ints "1", ["1hello", "1"], "+1", "-1"
  it_lexes_floats "1.0", ["1.0hello", "1.0"], "+1.0", "-1.0"
  it_lexes_char "'a'", ?a.ord
  it_lexes_char "'\\n'", ?\n.ord
  it_lexes_char "'\\t'", ?\t.ord
  it_lexes_operators "=", "<", "<=", ">", ">=", "+", "-", "*", "/", "(", ")", "==", "!=", "!", ",", '.', '#=>', "+@", "-@", "&&", "||", "|", "{", "}", '?', ':', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '**=', '<<', '>>', '%', '&', '|', '^', '**'
end
