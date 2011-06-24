require(File.expand_path("../../lib/crystal",  __FILE__))

include Crystal

describe "ast nodes" do
  it "should to_s Int" do
    Int.new(5).to_s.should eq('5')
  end

  [
    [Add, "+"],
    [Sub, "-"],
    [Mul, "*"],
    [Div, "/"],
    [LT, "<"],
    [LET, "<="],
    [EQ, "=="],
    [GT, ">"],
    [GET, ">="],
  ].each do |node, op|
    it "should to_s #{node}" do
      node.new(Int.new(5), Int.new(6)).to_s.should eq("5 #{op} 6")
    end
  end

  it "should to_s Def with no args" do
    Def.new("foo", [], Int.new(1)).to_s.should eq("def foo\n  1\nend")
  end

  it "should to_s Def with args" do
    Def.new("foo", [Arg.new('var')], Int.new(1)).to_s.should eq("def foo(var)\n  1\nend")
  end

  it "should to_s Ref" do
    Ref.new("foo").to_s.should eq("foo")
  end

  it "should to_s Call with no args" do
    Call.new("foo").to_s.should eq("foo()")
  end

  it "should to_s Call with args" do
    Call.new("foo", Int.new(1), Int.new(2)).to_s.should eq("foo(1, 2)")
  end
end
