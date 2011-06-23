require(File.expand_path("../../lib/lexer",  __FILE__))
require(File.expand_path("../../lib/parser",  __FILE__))

describe Parser do
  it "parses number" do
    nodes = Parser.parse("1")
    nodes.length.should == 1

    nodes[0].class.should eq(Int)
    nodes[0].value.should eq(1)
  end

  it "parses positive number" do
    nodes = Parser.parse("+1")
    nodes.length.should == 1

    nodes[0].class.should eq(Int)
    nodes[0].value.should eq(1)
  end

  it "parses negative number" do
    nodes = Parser.parse("-1")
    nodes.length.should == 1

    nodes[0].class.should eq(Int)
    nodes[0].value.should eq(-1)
  end

  it "parses add" do
    nodes = Parser.parse("1 + 2")
    nodes.length.should == 1

    nodes[0].class.should eq(Add)
    nodes[0].left.class.should eq(Int)
    nodes[0].left.value.should eq(1)
    nodes[0].right.class.should eq(Int)
    nodes[0].right.value.should eq(2)
  end

  it "parses add with new line" do
    nodes = Parser.parse("1 +\n2")
    nodes.length.should == 1

    nodes[0].class.should eq(Add)
    nodes[0].left.class.should eq(Int)
    nodes[0].left.value.should eq(1)
    nodes[0].right.class.should eq(Int)
    nodes[0].right.value.should eq(2)
  end

  it "parses number and newline minus number" do
    nodes = Parser.parse("1\n-2")
    nodes.length.should == 2

    nodes[0].value.should eq(1)
    nodes[1].value.should eq(-2)
  end
end
