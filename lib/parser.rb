require 'rltk/parser'
require(File.expand_path("../../lib/ast",  __FILE__))

class Parser < RLTK::Parser
  production(:e) do
    clause('INT') { |n| Int.new n }
  end

  finalize
end
