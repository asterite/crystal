require(File.expand_path("../../lib/lexer",  __FILE__))
require(File.expand_path("../../lib/parser",  __FILE__))

describe Parser do
  def self.it_parses(string, expected_nodes)
    it "parses #{string}" do
      Parser.parse(string).should eq(expected_nodes)
    end
  end

  def self.it_parses_single_node(string, expected_node)
    it_parses string, [expected_node]
  end

  it_parses_single_node "1", Int.new(1)
  it_parses_single_node "+1", Int.new(1)
  it_parses_single_node "-1", Int.new(-1)
  it_parses_single_node "1 + 2", Add.new(Int.new(1), Int.new(2))
  it_parses_single_node "1 +\n2", Add.new(Int.new(1), Int.new(2))
  it_parses "1\n+2", [Int.new(1), Int.new(2)]
  it_parses_single_node "1 - 2", Sub.new(Int.new(1), Int.new(2))
  it_parses_single_node "1 -\n2", Sub.new(Int.new(1), Int.new(2))
  it_parses "1\n-2", Sub.new(Int.new(1), Int.new(2))
  it_parses_single_node "1 * 2", Mul.new(Int.new(1), Int.new(2))
end
