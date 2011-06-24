require(File.expand_path("../../../lib/crystal",  __FILE__))

mod = Crystal::Module.new
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
