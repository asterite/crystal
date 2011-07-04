require(File.expand_path("../../lib/crystal",  __FILE__))

describe "ast eval" do
  def self.it_evals(string, expected_value, options = {})
    it "evals #{string}", options do
      mod = Crystal::Module.new
      value = mod.eval string
      value.should eq(expected_value)
    end
  end

  def self.it_evals_class(string, expected_value, options = {})
    it "evals class #{string}", options do
      mod = Crystal::Module.new
      value = mod.eval string
      expected_value = mod.find_expression expected_value
      value.should eq(expected_value)
    end
  end

  it_evals "true", true
  it_evals "5", 5
  it_evals "1 + 2", 3
  it_evals "1 - 2", -1
  it_evals "4 / 2", 2
  it_evals "4 * 2", 8
  it_evals "2 * (3 + 4)", 14
  it_evals "8 < 4", false
  it_evals "4 < 8", true
  it_evals "8 <= 7", false
  it_evals "8 <= 8", true
  it_evals "8 > 4", true
  it_evals "4 > 8", false
  it_evals "8 >= 9", false
  it_evals "8 >= 8", true
  it_evals "8 == 8", true
  it_evals "8 == 9", false
  it_evals "true == false", false
  it_evals "true == true", true
  it_evals "+ 1", 1
  it_evals "- 1", -1
  it_evals "def foo; end", nil
  it_evals "def foo; 1; end", nil
  it_evals "def foo; 1; end; foo", 1
  it_evals "def foo; 1; 2; end; foo", 2
  it_evals "def foo; 1; end; def foo; 2; end; foo", 2
  it_evals "def foo(var); 1; end; foo(2)", 1
  it_evals "def foo(var); var + 1; end; foo(2)", 3
  it_evals "def foo; bar baz; end; def bar(x); x; end; def baz; 10; end; foo", 10
  it_evals "if 1; 2; end", 2
  it_evals "if 0; 3; end", 0
  it_evals "if 0; 1; else; 3; end", 3
  it_evals "def fact(n); if n <= 1; 1; else; n * fact(n -1); end; end; fact(1)", 1
  it_evals "def fact(n); if n <= 1; 1; else; n * fact(n -1); end; end; fact(4)", 24
  it_evals_class "Class", "Class"
  ["false.class", "true.class", "Bool"].each do |string|
    it_evals_class string, "Bool"
  end
  ["1.class", "Int"].each do |string|
    it_evals_class string, "Int"
  end
  it_evals "extern puti Int #=> Int; C.puti 1", 1
  it_evals "class Int; end", nil
  it_evals "class Int; def foo; 2; end; end; 1.foo", 2
  it_evals "class Int; def foo(bar); bar; end; end; 1.foo 2", 2
  it_evals "class Int; def foo(bar, baz); bar + baz; end; end; 1.foo 2, 3", 5
  it_evals "def foo x; x = 3; x; end; foo 2", 3
  it_evals "def foo x; x = 3; end; foo 2", 3
  it_evals "def foo; x = 3; x; end; foo", 3
  it_evals "def foo; x = 3; x = 4; end; foo", 4
  it_evals "def fact(n); if n <= 1; n = 1; else; n = n * fact(n -1); end; end; fact(1)", 1
  it_evals "def foo; x = 10; while x > 3; x = x - 1; end; x; end; foo", 3
end
