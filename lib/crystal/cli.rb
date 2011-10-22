require(File.expand_path("../../../lib/crystal",  __FILE__))
require 'readline'
require(File.expand_path("../../../lib/crystal/core_ext/readline",  __FILE__))

mod = Crystal::Module.new
result = nil

def count_openings(string)
  openings = 0

  lexer = Crystal::Lexer.new string
  last_token = nil
  while (token = lexer.next_token).type != :EOF
    case token.type
    when :SPACE
      next
    when :IDENT
      case token.value
      when :class, :def, :if, :If, :unless, :Unless, :while
        openings += 1 if last_token.nil? || last_token == :';' || last_token == :NEWLINE
      when :do
        openings += 1
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

Readline.read_history

loop do
  line = Readline.readline "crystal > #{ '  ' * openings }", true
  next if line.strip.empty?

  break if line.strip == "exit" || line.strip == "quit"
  next mod.dump if line.strip == "dump"

  buffer << line << "\n"
  openings = count_openings buffer

  if openings == 0
    begin
      result = mod.eval buffer
      puts " => #{result.nil? ? 'nil' : result}"
    rescue => ex
      puts ex
      #puts ex.backtrace
    end

    buffer = ""
  end
end
