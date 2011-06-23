require(File.expand_path("../../lib/lexer",  __FILE__))
require(File.expand_path("../../lib/parser",  __FILE__))

describe Parser do
  def self.it_parses(string, expected_nodes, options = {})
    it "parses #{string}", options do
      node = Parser.parse(string)
      node.should eq(expected_nodes)
    end
  end

  def self.it_parses_single_node(string, expected_node, options = {})
    it_parses string, [expected_node], options
  end

  it_parses_single_node "1", Int.new(1)
  it_parses_single_node "+1", Int.new(1)
  it_parses_single_node "-1", Int.new(-1)
  it_parses_single_node "1 + 2", Add.new(Int.new(1), Int.new(2))
  it_parses_single_node "1 +\n2", Add.new(Int.new(1), Int.new(2))
  it_parses "1\n+2", [Int.new(1), Int.new(2)]
  it_parses "1;+2", [Int.new(1), Int.new(2)]
  it_parses_single_node "1 - 2", Sub.new(Int.new(1), Int.new(2))
  it_parses_single_node "1 -\n2", Sub.new(Int.new(1), Int.new(2))
  it_parses "1\n-2", [Int.new(1), Int.new(-2)]
  it_parses "1;-2", [Int.new(1), Int.new(-2)]
  it_parses_single_node "1 * 2", Mul.new(Int.new(1), Int.new(2))
  it_parses_single_node "1 * -2", Mul.new(Int.new(1), Int.new(-2))
  it_parses_single_node "2 * 3 + 4 * 5", Add.new(Mul.new(Int.new(2), Int.new(3)), Mul.new(Int.new(4), Int.new(5)))
  it_parses_single_node "1 / 2", Div.new(Int.new(1), Int.new(2))
  it_parses_single_node "1 / -2", Div.new(Int.new(1), Int.new(-2))
  it_parses_single_node "2 / 3 + 4 / 5", Add.new(Div.new(Int.new(2), Int.new(3)), Div.new(Int.new(4), Int.new(5)))

  it_parses_single_node "def foo\n1\nend", Def.new("foo", [], Int.new(1))
  it_parses_single_node "def foo ; 1 ; end", Def.new("foo", [], Int.new(1))
  it_parses_single_node "def foo; end", Def.new("foo", [], nil)
  it_parses_single_node "def foo(var); end", Def.new("foo", [Arg.new("var")], nil)
  it_parses_single_node "def foo(\nvar); end", Def.new("foo", [Arg.new("var")], nil)
  it_parses_single_node "def foo(\nvar\n); end", Def.new("foo", [Arg.new("var")], nil)
  it_parses_single_node "def foo(var1, var2); end", Def.new("foo", [Arg.new("var1"), Arg.new("var2")], nil)
  it_parses_single_node "def foo(\nvar1\n,\nvar2\n)\n end", Def.new("foo", [Arg.new("var1"), Arg.new("var2")], nil)
  it_parses_single_node "def foo var; end", Def.new("foo", [Arg.new("var")], nil)
  it_parses_single_node "def foo var\n end", Def.new("foo", [Arg.new("var")], nil)
  it_parses_single_node "def foo var1, var2\n end", Def.new("foo", [Arg.new("var1"), Arg.new("var2")], nil)
  it_parses_single_node "def foo var1,\nvar2\n end", Def.new("foo", [Arg.new("var1"), Arg.new("var2")], nil)

  it_parses_single_node "foo", Call.new("foo")
end
