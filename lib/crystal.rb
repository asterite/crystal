module Crystal
  class Exception < StandardError
    attr_accessor :line_number

    def initialize(message, line_number)
      super(message)
      @line_number = line_number
    end
  end
end

[
  'ast',
  'array',
  'builtin',
  'class',
  'codegen',
  'compile_time',
  'eval',
  'instance',
  'lexer',
  'parser',
  'resolve',
  'scope',
  'token',
  'to_s',
  'yield',
  'visitor',
  'core_ext/false_class',
  'core_ext/fixnum',
  'core_ext/float',
  'core_ext/string',
  'core_ext/true_class',
].each do |filename|
  require(File.expand_path("../../lib/crystal/#{filename}",  __FILE__))
end
