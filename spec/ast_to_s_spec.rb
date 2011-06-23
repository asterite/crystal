require(File.expand_path("../../lib/ast",  __FILE__))

describe "ast nodes" do
  it "should to_s Int" do
    Int.new(5).to_s.should eq('5')
  end

  it "should to_s Add" do
    Add.new(Int.new(5), Int.new(6)).to_s.should eq("5 + 6")
  end
end
