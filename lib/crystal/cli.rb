require(File.expand_path("../../../lib/crystal",  __FILE__))

mod = Crystal::Module.new
result = nil

def count_openings(string)
  openings = 0

  lexer = Crystal::Lexer.new string
  last_token = nil
  while (token = lexer.next_token).type != :EOF
    if token.type == :IDENT
      case token.value
      when :def, :if, :If, :class, :while
        openings += 1 if last_token.nil? || last_token != :'.'
      when :end, :End
        openings -= 1
      end
    end
    last_token = token.type
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

  break if line.strip == "exit" || line.strip == "quit"
  next mod.dump if line.strip == "dump"

  buffer << line
  openings = count_openings buffer

  if openings == 0
    begin
      result = mod.eval buffer
      puts " => #{result.nil? ? 'nil' : result}"
    rescue => ex
      puts ex
      # puts ex.backtrace
    end

    buffer = ""
  end
end
