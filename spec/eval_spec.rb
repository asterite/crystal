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
  it_evals "1.0", 1.0.float
  it_evals "'a'", Crystal::Char.new(?a.ord)
  it_evals "'a' == 'a'", true.bool
  it_evals "a = 1; a += 2; a", 3.int
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
  it_evals "if false; 3.0; end", 0.0.float
  it_evals "if false; 'a'; end", Crystal::Char.new(0)
  it_evals "if false; nil; end", Crystal::Nil.new
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
  it_evals "class Foo < Int; end;", nil
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
  it_evals "5.times { |x| 5.times { |y| y } }", 5.int
  it_evals "5.times { 1 }", 5.int
  it_evals "class Int; def !=(other); self + other == 42; end; end; 21 != 21", true.bool
  it_evals "def foo; yield 11; end; def bar; a = 31; foo { |x| a + x }; end; bar", 42.int
  it_evals "def foo; yield 11; end; def bar; a = 21; a = a + 10; foo { |x| a + x }; end; bar", 42.int
  it_evals "def foo; yield 42; end; def bar; a = 21; foo { |x| a = x }; end; bar", 42.int
  it_evals "def foo; yield 21; end; def bar; a = 21; foo { |x| a = a + x }; end; bar", 42.int
  it_evals "def foo; yield 11; end; def bar(a); a = a + 10; foo { |x| a + x }; end; bar(21)", 42.int
  it_evals "def foo; yield 42; end; def bar; foo { |x| foo { |y| x } }; end; bar", 42.int
  it_evals "def foo; yield 21; end; def bar; foo { |x| foo { |y| x + y } }; end; bar", 42.int
  it_evals "def foo; yield 42; end; def bar; x = 10; foo { |x| x }; end; bar", 42.int
  it_evals "def foo; yield 21; end; def bar; a = 10; a = a + 11; foo { |x| foo { |y| x + a } }; end; bar", 42.int
  it_evals "def foo; yield 21; end; def bar; a = 10; a = a + 11; foo { |x| foo { |y| a = 50 } }; end; bar", 50.int
  it_evals "def foo; yield 21; end; def bar; a = 1; a = a + 2; b = 4; b = b + 14; foo { |x| foo { |y| x + a + b} }; end; bar", 42.int
  it_evals "def foo; yield 21; end; def bar; a = 10; a = a + 11; foo { |x| foo { |y| foo { |z| a + z} } }; end; bar", 42.int
  it_evals "def foo; yield 21; end; def bar; a = 10; a = a + 11; foo { |x| foo { |y| foo { |z| foo { |w| a + w } } } }; end; bar", 42.int
  it_evals "def foo; yield 42; end; def bar; a = 10; a = a + 2; foo { |x| foo { |y| foo { |z| foo { |w| a = w } } } }; a; end; bar", 42.int
  it_evals "def foo; yield 42; end; def bar; a = 10; foo { |x| foo { |y| foo { |z| a = y } } }; a; end; bar", 42.int
  it_evals "def foo; yield 42; end; def bar; a = 10; foo { |x| foo { |y| foo { |z| a = x } } }; a; end; bar", 42.int
  it_evals "def foo; return 1; end; foo", 1.int
  it_evals "def foo; return 1; 2; end; foo", 1.int
  it_evals "def foo; return; end", nil
  it_evals "def foo; yield 1; yield 2; end; def bar; foo { |x| return x }; end; bar", 1.int
  it_evals "def foo; yield 1; yield 2; end; def bar; foo { |x| next x; 10 }; end; bar", 2.int
  it_evals "def foo; yield 1; yield 2; end; def bar; foo { |x| next x if x == 1; 10 }; end; bar", 10.int
  it_evals "def foo; yield 1; yield 2; end; def bar; foo { |x| break x; 10 }; end; bar", 1.int
  it_evals "a = 0; def bar; 10.times { |x| a += x; break if x > 5 }; end; bar", 0.int
  it_evals "def bar; a = 10.times { |x| break if x > 5 }; a; end; bar", 0.int
  it_evals "def bar; a = 10.times { |x| break 5 if x > 5 }; a; end; bar", 5.int
  it_evals "def foo; yield 2; yield 3; end; def bar; foo { |x| return 1.0 if x == 2; 1 }; 2.0; end; bar", 1.0.float
  it_evals "def foo; yield 2; 'a'; end; def bar; foo { |x| 1 }; end; bar", Crystal::Char.new(?a.ord)
  it_evals "def foo; yield 2; end; def bar; foo { |x| foo { |y| return 3.0 } }; 2.0; end; bar", 3.0.float
  it_evals "class Int; def foo; 1; end; def bar; foo; end; end; 5.bar", 1.int
  it_evals "def foo; 1; end; class Int; def bar; foo; end; end; 5.bar", 1.int
  it_evals "class Int; def foo(x); x; end; def bar(x); foo(x); end; end; 5.bar(1)", 1.int
  it_evals "def foo(x); x; end; class Int; def bar(x); foo(x); end; end; 5.bar(1)", 1.int
  it_evals "def Int.foo; 1; end; Int.foo", 1.int
  it_evals "def Int.foo; 1; end; 1 + 2", 3.int
  it_evals "def Int.foo(x); x + 2; end; Int.foo(1)", 3.int
end
