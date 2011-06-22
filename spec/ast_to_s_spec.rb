require(File.expand_path("../../lib/ast",  __FILE__))

describe "ast nodes" do
  it "Int#to_s" do
    Int.new(5).to_s.should eq('5')
  end
end
