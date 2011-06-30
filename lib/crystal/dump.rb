require(File.expand_path("../../../lib/crystal",  __FILE__))

if ARGV.length != 1
  puts "Usage: dump FILE"
  exit
end

filename = ARGV[0]
file = File.read filename

mod = Crystal::Module.new
mod.compile file
mod.create_main
mod.dump
