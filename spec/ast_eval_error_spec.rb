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
end
