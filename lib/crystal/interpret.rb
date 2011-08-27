require(File.expand_path("../../../lib/crystal",  __FILE__))

if ARGV.length != 1
  puts "Usage: interpret FILE"
  exit
end

filename = ARGV[0]
file = File.read filename

mod = Crystal::Module.new
begin
  mod.eval file
rescue => ex
  puts ex
end
