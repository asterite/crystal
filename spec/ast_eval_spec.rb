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
  it_evals "1 + 2", 3, :focus => true
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
  it_evals "false && true", false
  it_evals "true && true", true
  it_evals "false || false", false
  it_evals "false || true", true
  it_evals "1.0", 1.0
  it_evals "def foo; end", nil
  it_evals "def foo; end; foo", nil
  it_evals "def foo; 1; end", nil
  it_evals "def foo; 1; end; foo", 1
  it_evals "def foo; 1; 2; end; foo", 2
  it_evals "def foo; 1; end; def foo; 2; end; foo", 2
  it_evals "def foo(var); 1; end; foo(2)", 1
  it_evals "def foo(var); var + 1; end; foo(2)", 3
  it_evals "def foo; bar baz; end; def bar(x); x; end; def baz; 10; end; foo", 10
  it_evals "if true; 2; end", 2
  it_evals "if false; 3; end", 0
  it_evals "if false; 1; else; 3; end", 3
  it_evals "def fact(n); if n <= 1; 1; else; n * fact(n -1); end; end; fact(1)", 1
  it_evals "def fact(n); if n <= 1; 1; else; n * fact(n -1); end; end; fact(4)", 24
  it_evals_class "Class", "Class"
  ["false.class", "true.class", "Bool"].each do |string|
    it_evals_class string, "Bool"
  end
  ["1.class", "Int"].each do |string|
    it_evals_class string, "Int"
  end
  it_evals "extern puti Int #=> Nil; C.puti 1", nil
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
  it_evals "a = 10; a = a + 20; a", 30
  it_evals "a = 10; b = 5; while a > 5; while b > 2; b = b - 1; end; a = a - 1; end; a + b", 7
  it_evals "def bar x; if 1 > 2; 2; else; 1; end; end; bar 8; def foo; if 1 > 2; 1; else; 2; end; end; foo", 2
  it_evals "def fib n; if n <= 2; 1; else; fib(n - 1) + fib(n - 2); end; end; fib 10", 55
  it_evals "If true; 1; Else; false; End", 1
  it_evals "If false; 1; Else; false; End", false
  it_evals "def foo; If true; 1; Else; false; End; end; foo", 1, :focus => true
end
