require(File.expand_path("../../lib/crystal",  __FILE__))

include Crystal

describe "ast resolve" do
  def self.it_resolves(string, expected_type, options = {})
    it "resolves #{string}", options do
      mod = Crystal::Module.new
      last = mod.compile string
      if expected_type.nil?
        last.should be_nil
      else
        expected_type = mod.find_expression expected_type
        last.resolved_type.should eq(expected_type)
      end
    end
  end

  it_resolves "nil", "Nil"
  it_resolves "true", "Bool"
  it_resolves "false", "Bool"
  it_resolves "1", "Int"
  it_resolves "1 + 2", "Int"
  it_resolves "1 - 2", "Int"
  it_resolves "1 * 2", "Int"
  it_resolves "1 / 2", "Int"
  it_resolves "1 + (2 * 3)", "Int"
  it_resolves "1 < 2", "Bool"
  it_resolves "def foo; 1; end", nil
  it_resolves "while true; end", "Nil"
  it_resolves "def foo; 1; end; foo", "Int"
  it_resolves "def foo; 1; end; foo()", "Int"
  it_resolves "def foo(x); 1; end; foo 1", "Int"
  it_resolves "def foo(x); x; end; foo 1", "Int"
  it_resolves "def foo(x); x; end; foo true", "Bool"
  it_resolves "def foo(x); x; end; foo 1; foo true", "Bool"
  it_resolves "def foo(x); if true; x; else; foo(x); end; end; foo(1)", "Int"
  it_resolves "def foo(x); if false; foo(x); else; 1; end; end; foo(1)", "Int"
end
