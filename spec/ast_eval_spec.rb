require(File.expand_path("../../lib/ast",  __FILE__))
require(File.expand_path("../../lib/codegen",  __FILE__))
require(File.expand_path("../../lib/parser",  __FILE__))

describe "ast eval" do
  def self.it_evals(string, expected_value)
    it "evals #{string}" do
      mod = Module.new
      value = mod.eval string
      value.should eq(expected_value)
    end
  end

  it_evals "5", 5
  it_evals "1 + 2", 3
  it_evals "def foo; end", nil
  it_evals "def foo; 1; end", nil
  it_evals "def foo; 1; end; foo", 1
  it_evals "def foo; 1; end; def foo; 2; end; foo", 2
end
