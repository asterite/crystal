require(File.expand_path("../../../lib/crystal",  __FILE__))

mod = Crystal::Module.new
result = nil

def count_openings(string)
  openings = 0

  lexer = Crystal::Lexer.new string
  while (token = lexer.next_token).type != :EOF
    if token.type == :IDENT
      if token.value == :def
        openings += 1
      elsif token.value == :end
        openings -= 1
      end
    end
  end
  openings
end

buffer = ""
openings = 0

loop do
  print "crystal > "
  print ("  " * openings)
  line = gets
  next if line.strip.empty?

  buffer << line
  openings = count_openings buffer

  if openings == 0
    break if line.strip == "exit" || line.strip == "quit"

    begin
      result = mod.eval buffer
      puts " => #{result ? result : 'nil'}"
    rescue => ex
      puts ex
    end

    buffer = ""
  end
end
