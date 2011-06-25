require(File.expand_path("../../lib/crystal",  __FILE__))

describe "ast eval" do
  def self.it_evals(string, expected_value, options = {})
    it "evals #{string}", options do
      mod = Crystal::Module.new
      value = mod.eval string
      value.should eq(expected_value)
    end
  end

  it_evals "5", 5
  it_evals "1 + 2", 3
  it_evals "1 - 2", -1
  it_evals "4 / 2", 2
  it_evals "4 * 2", 8
  it_evals "2 * (3 + 4)", 14
  it_evals "8 < 4", 0
  it_evals "4 < 8", 1
  it_evals "8 <= 7", 0
  it_evals "8 <= 8", 1
  it_evals "8 > 4", 1
  it_evals "4 > 8", 0
  it_evals "8 >= 9", 0
  it_evals "8 >= 8", 1
  it_evals "8 == 8", 1
  it_evals "8 == 9", 0
  it_evals "def foo; end", nil
  it_evals "def foo; 1; end", nil
  it_evals "def foo; 1; end; foo", 1
  it_evals "def foo; 1; 2; end; foo", 2
  it_evals "def foo; 1; end; def foo; 2; end; foo", 2
  it_evals "def foo(var); 1; end; foo(2)", 1
  it_evals "def foo(var); var + 1; end; foo(2)", 3, :focus => true
end
