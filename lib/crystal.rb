require(File.expand_path("../../lib/parser",  __FILE__))
require(File.expand_path("../../lib/codegen",  __FILE__))

mod = Module.new
result = nil

loop do
  print "crystal > "
  line = gets.strip
  break if line == "exit" || line == "quit"

  begin
    nodes = Parser.parse line
    nodes.each do |node|
      result = mod.define node
    end

    puts " => #{result}"
  rescue => ex
    puts ex
  end
end
