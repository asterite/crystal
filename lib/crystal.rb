require(File.expand_path("../../lib/parser",  __FILE__))

loop do
  print "crystal > "
  line = gets.strip
  break if line == "exit" || line == "quit"

  nodes = Parser.parse(line)
  puts " => #{nodes.last}"
end
