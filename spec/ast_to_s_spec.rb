require(File.expand_path("../../lib/ast",  __FILE__))

describe "ast nodes" do
  it "should to_s Int" do
    Int.new(5).to_s.should eq('5')
  end

  [
    [Add, "+"],
    [Sub, "-"],
    [Mul, "*"],
    [Div, "/"]
  ].each do |node, op|
    it "should to_s #{node}" do
      node.new(Int.new(5), Int.new(6)).to_s.should eq("5 #{op} 6")
    end
  end

  it "should to_s Def" do
    Def.new("foo", [], Int.new(1)).to_s.should eq("def foo\n  1\nend")
  end

  it "should to_s Call" do
    Call.new("foo").to_s.should eq("foo")
  end
end
