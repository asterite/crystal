require(File.expand_path("../../lib/crystal",  __FILE__))

include Crystal

describe Parser do
  def self.it_parses(string, expected_nodes, options = {})
    it "parses #{string}", options do
      node = Parser.parse(string)
      node.should eq(Expressions.new expected_nodes)
    end
  end

  def self.it_parses_single_node(string, expected_node, options = {})
    it_parses string, [expected_node], options
  end

  it_parses_single_node "1", 1.int
  it_parses_single_node "+1", 1.int
  it_parses_single_node "-1", -1.int
  it_parses_single_node "1 + 2", Add.new(1.int, 2.int)
  it_parses_single_node "1 +\n2", Add.new(1.int, 2.int)
  it_parses "1\n+2", [1.int, 2.int]
  it_parses "1;+2", [1.int, 2.int]
  it_parses_single_node "1 - 2", Sub.new(1.int, 2.int)
  it_parses_single_node "1 -\n2", Sub.new(1.int, 2.int)
  it_parses "1\n-2", [1.int, -2.int]
  it_parses "1;-2", [1.int, -2.int]
  it_parses_single_node "1 * 2", Mul.new(1.int, 2.int)
  it_parses_single_node "1 * -2", Mul.new(1.int, -2.int)
  it_parses_single_node "2 * 3 + 4 * 5", Add.new(Mul.new(2.int, 3.int), Mul.new(4.int, 5.int))
  it_parses_single_node "1 / 2", Div.new(1.int, 2.int)
  it_parses_single_node "1 / -2", Div.new(1.int, -2.int)
  it_parses_single_node "2 / 3 + 4 / 5", Add.new(Div.new(2.int, 3.int), Div.new(4.int, 5.int))

  it_parses_single_node "(1)", 1.int
  it_parses_single_node "2 * (3 + 4)", Mul.new(2.int, Add.new(3.int, 4.int))

  it_parses_single_node "def foo\n1\nend", Def.new("foo", [], [1.int])
  it_parses_single_node "def foo ; 1 ; end", Def.new("foo", [], [1.int])
  it_parses_single_node "def foo; end", Def.new("foo", [], nil)
  it_parses_single_node "def foo(var); end", Def.new("foo", ["var".arg], nil)
  it_parses_single_node "def foo(\nvar); end", Def.new("foo", ["var".arg], nil)
  it_parses_single_node "def foo(\nvar\n); end", Def.new("foo", ["var".arg], nil)
  it_parses_single_node "def foo(var1, var2); end", Def.new("foo", ["var1".arg, "var2".arg], nil)
  it_parses_single_node "def foo(\nvar1\n,\nvar2\n)\n end", Def.new("foo", ["var1".arg, "var2".arg], nil)
  it_parses_single_node "def foo var; end", Def.new("foo", ["var".arg], nil)
  it_parses_single_node "def foo var\n end", Def.new("foo", ["var".arg], nil)
  it_parses_single_node "def foo var1, var2\n end", Def.new("foo", ["var1".arg, "var2".arg], nil)
  it_parses_single_node "def foo var1,\nvar2\n end", Def.new("foo", ["var1".arg, "var2".arg], nil)

  it_parses_single_node "def foo; 1; 2; end", Def.new("foo", [], [1.int, 2.int])

  it_parses_single_node "foo", "foo".ref
  it_parses_single_node "foo(1)", Call.new("foo", 1.int)
  it_parses_single_node "foo 1", Call.new("foo", 1.int)
  it_parses_single_node "foo 1\n", Call.new("foo", 1.int)
  it_parses_single_node "foo 1;", Call.new("foo", 1.int)
  it_parses_single_node "foo 1, 2", Call.new("foo", 1.int, 2.int)
  it_parses_single_node "foo (1 + 2), 3", Call.new("foo", Add.new(1.int, 2.int), 3.int)
  it_parses_single_node "foo(1 + 2)", Call.new("foo", Add.new(1.int, 2.int))

  it_parses_single_node "foo", "foo".ref
  it_parses_single_node "foo + 1", Add.new("foo".ref, 1.int)
  it_parses_single_node "foo +1", Call.new("foo", 1.int)

  it_parses_single_node "1 < 2", LT.new(1.int, 2.int)
  it_parses_single_node "1 <= 2", LET.new(1.int, 2.int)
  it_parses_single_node "1 == 2", EQ.new(1.int, 2.int)
  it_parses_single_node "1 > 2", GT.new(1.int, 2.int)
  it_parses_single_node "1 >= 2", GET.new(1.int, 2.int)

  #it_parses_single_node "if foo; 1; end", If.new("foo".ref, 1.int)
end
