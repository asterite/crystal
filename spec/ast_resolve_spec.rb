require(File.expand_path("../../lib/crystal",  __FILE__))

include Crystal

describe "ast resolve" do
  def self.it_resolves(string, expected_type, options = {})
    it "resolves #{string}", options do
      mod = Crystal::Module.new
      exps = Parser.parse string
      mod.define *exps.expressions
      exps.expressions.last.resolved_type.should eq(expected_type)
    end
  end

  it_resolves "1", Int
  it_resolves "1 + 2", Int
  it_resolves "1 - 2", Int
  it_resolves "1 * 2", Int
  it_resolves "1 / 2", Int
  it_resolves "1 + (2 * 3)", Int
  it_resolves "def foo; 1; end", nil
  it_resolves "def foo; 1; end; foo", Int
  it_resolves "def foo; 1; end; foo()", Int
  it_resolves "def foo(x); 1; end; foo(1)", Int
  it_resolves "def foo(x); x; end; foo(1)", Int
  it_resolves "def foo(x); if 1; x; else; foo(x); end; end; foo(1)", Int
  it_resolves "def foo(x); if 0; foo(x); else; 1; end; end; foo(1)", Int
end
