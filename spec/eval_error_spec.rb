require(File.expand_path("../../lib/crystal",  __FILE__))

describe "ast eval" do
  def self.it_evals_with_error(string, options = {})
    it "evals with error #{string}", options do
      mod = Crystal::Module.new
      begin
        mod.eval string
        fail
      rescue => ex
      end
    end
  end

  it_evals_with_error "def foo x; x + 2; end; x + 1; false + 1"
  it_evals_with_error "def foo; a = 10; yield 42; end; def bar; foo { |x| a }; end; bar"
  it_evals_with_error "def bar; a = 10.times { |x| break 1.0 if x > 5 }; a; end; bar"
  it_evals_with_error "def bar; a = 10.times { |x| next 1.0 if x > 5 }; a; end; bar"
end
