require(File.expand_path("../../lib/parser",  __FILE__))
require(File.expand_path("../../lib/codegen",  __FILE__))

mod = Module.new
result = nil

loop do
  print "crystal > "
  line = gets.strip
  next if line.empty?
  break if line == "exit" || line == "quit"

  begin
    result = mod.eval line
    puts " => #{result ? result : 'nil'}"
  rescue => ex
    puts ex
  end
end
