require(File.expand_path("../../lib/crystal",  __FILE__))

describe "ast eval" do
  def self.it_evals_with_error(string, line_number, message, options = {})
    it "evals with error #{string}", options do
      mod = Crystal::Module.new
      begin
        mod.eval string
        fail "Expected to fail"
      rescue Crystal::Exception => ex
        ex.line_number.should eq(line_number)
        ex.message.should =~ message
      end
    end
  end

  it_evals_with_error "def Foo\nend\nclass Foo\nend", 3, /can only extend a class/
  it_evals_with_error "\nclass Bar < Foo\nend", 2, /unknown class 'Foo'/
  it_evals_with_error "def Foo\nend\nclass Bar < Foo\nend", 3, /can only inherit from a class/
  it_evals_with_error "\nfoo", 2, /undefined local variable or method 'foo'/
  it_evals_with_error "def foo x; x + 2; end; x + 1; false + 1", 1, //
  it_evals_with_error "def foo; a = 10; yield 42; end; def bar; foo { |x| a }; end; bar", 1, //
  it_evals_with_error "def bar; a = 10.times { |x| break 1.0 if x > 5 }; a; end; bar", 1, //
  it_evals_with_error "def bar; a = 10.times { |x| next 1.0 if x > 5 }; a; end; bar", 1, //
  it_evals_with_error "def foo; yield 1; end; foo", 1, //
  it_evals_with_error "def foo; yield 1; yield 1.0; end; foo {|x| }", 1, //
  it_evals_with_error "def foo; yield 2; yield 3; end; def bar; foo { |x| return 1.0 if x == 2; 1 }; 1; end; bar", 1, //
end
