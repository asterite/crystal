require(File.expand_path("../../lib/lexer",  __FILE__))
require(File.expand_path("../../lib/parser",  __FILE__))

describe Parser do
  it "parses number" do
    node = Parser.parse(Lexer.lex("1"))
    node.class.should eq(Int)
    node.value.should eq(1)
  end
end
