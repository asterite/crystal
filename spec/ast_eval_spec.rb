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

  it_evals "true", true.bool
  it_evals "5", 5.int
  it_evals "1 + 2", 3.int
  it_evals "1 + 2.0", 3.0.float
  it_evals "1.0 + 2", 3.0.float
  it_evals "1 - 2", -1.int
  it_evals "1 - 2.0", -1.0.float
  it_evals "1.0 - 2", -1.0.float
  it_evals "4 / 2", 2.int
  it_evals "4.0 / 2", 2.0.float
  it_evals "4 / 2.0", 2.0.float
  it_evals "4 * 2", 8.int
  it_evals "4 * 2.0", 8.0.float
  it_evals "4.0 * 2", 8.0.float
  it_evals "2 * (3 + 4)", 14.int
  it_evals "8 < 4", false.bool
  it_evals "8.0 < 4", false.bool
  it_evals "8 < 4.0", false.bool
  it_evals "4 < 8", true.bool
  it_evals "8 <= 7", false.bool
  it_evals "8 <= 8", true.bool
  it_evals "8.0 <= 7", false.bool
  it_evals "8 <= 7.0", false.bool
  it_evals "8 > 4", true.bool
  it_evals "4 > 8", false.bool
  it_evals "8.0 > 4", true.bool
  it_evals "8 > 4.0", true.bool
  it_evals "8 >= 9", false.bool
  it_evals "8 >= 8", true.bool
  it_evals "8.0 >= 9", false.bool
  it_evals "8 >= 9.0", false.bool
  it_evals "8 == 8", true.bool
  it_evals "8 == 9", false.bool
  it_evals "8.0 == 9", false.bool
  it_evals "8 == 9.0", false.bool
  it_evals "true == false", false.bool
  it_evals "true == true", true.bool
  it_evals "+ 1", 1.int
  it_evals "- 1", -1.int
  it_evals "false && true", false.bool
  it_evals "true && true", true.bool
  it_evals "false || false", false.bool
  it_evals "false || true", true.bool
  it_evals "1.0", 1.0.float
  it_evals "'a'", Crystal::Char.new(?a.ord)
  it_evals "'a' == 'a'", true.bool
  it_evals "def foo; end", nil
  it_evals "def foo; end; foo", Crystal::Nil.new
  it_evals "def foo; 1; end", nil
  it_evals "def foo; 1; end; foo", 1.int
  it_evals "def foo; 1; 2; end; foo", 2.int
  it_evals "def foo; 1; end; def foo; 2; end; foo", 2.int
  it_evals "def foo(var); 1; end; foo(2)", 1.int
  it_evals "def foo(var); var + 1; end; foo(2)", 3.int
  it_evals "def foo; bar baz; end; def bar(x); x; end; def baz; 10; end; foo", 10.int
  it_evals "if true; 2; end", 2.int
  it_evals "if false; 3; end", 0.int
  it_evals "if false; 1; else; 3; end", 3.int
  it_evals "def fact(n); if n <= 1; 1; else; n * fact(n -1); end; end; fact(1)", 1.int
  it_evals "def fact(n); if n <= 1; 1; else; n * fact(n -1); end; end; fact(4)", 24.int
  ["Bool.class", "Int.class", "Class"].each do |string|
    it_evals_class string, "Class"
  end
  ["false.class", "true.class", "Bool"].each do |string|
    it_evals_class string, "Bool"
  end
  ["1.class", "Int"].each do |string|
    it_evals_class string, "Int"
  end
  it_evals "extern puts_int Int #=> Nil; C.puts_int 1", Crystal::Nil.new
  it_evals "class Int; end", nil
  it_evals "class Int; def foo; 2; end; end; 1.foo", 2.int
  it_evals "class Int; def foo(bar); bar; end; end; 1.foo 2", 2.int
  it_evals "class Int; def foo(bar, baz); bar + baz; end; end; 1.foo 2, 3", 5.int
  it_evals "def foo x; x = 3; x; end; foo 2", 3.int
  it_evals "def foo x; x = 3; end; foo 2", 3.int
  it_evals "def foo; x = 3; x; end; foo", 3.int
  it_evals "def foo; x = 3; x = 4; end; foo", 4.int
  it_evals "def fact(n); if n <= 1; n = 1; else; n = n * fact(n -1); end; end; fact(1)", 1.int
  it_evals "def foo; x = 10; while x > 3; x = x - 1; end; x; end; foo", 3.int
  it_evals "a = 10; a = a + 20; a", 30.int
  it_evals "a = 10; b = 5; while a > 5; while b > 2; b = b - 1; end; a = a - 1; end; a + b", 7.int
  it_evals "def bar x; if 1 > 2; 2; else; 1; end; end; bar 8; def foo; if 1 > 2; 1; else; 2; end; end; foo", 2.int
  it_evals "def fib n; if n <= 2; 1; else; fib(n - 1) + fib(n - 2); end; end; fib 10", 55.int
  it_evals "If true; 1; Else; false; End", 1.int
  it_evals "If false; 1; Else; false; End", false.bool
  it_evals "def foo; If true; 1; Else; false; End; end; foo", 1.int
  it_evals "class Object; def foo(other); self + other; end; end; 1.foo(1); 1.0.foo(1.0)", 2.0.float
  it_evals "def foo X; If X == 1; 2; Else; 3; End; end; foo 1", 2.int
  it_evals "def foo X; If X == 1; 2; Else; 3; End; end; foo 2", 3.int
  it_evals "def foo X; If X == 1; 2; Else; 3; End; end; foo 1; foo 2", 3.int
  it_evals "def foo; yield 1; end; foo { |x| x + 2 }", 3.int
  it_evals "def foo; yield 1; end; foo { |x| x + 2 }; foo { |x| x + 3 }", 4.int
  it_evals "def foo; yield 1; end; foo { |x| x + 2 }; foo { |x| x > 0 }", true.bool
  it_evals "class Int; def foo; yield 1; end; end; 1.foo { |x| x + 2 }", 3.int
  it_evals "def foo; if true; while false; 1; end; end; 1; end; foo", 1.int
  it_evals "5.times { |x| x }", 5.int
  #it_evals "5.times { |x| 5.times { |y| y } }", 5.int
  it_evals "5.times { 1 }", 5.int, :focus => true
end
