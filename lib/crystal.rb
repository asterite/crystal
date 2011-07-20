[
  'ast',
  'ast_codegen',
  'ast_compile_time',
  'ast_eval',
  'ast_resolve',
  'ast_to_s',
  'ast_yield',
  'lexer',
  'parser',
  'token',
  'visitor',
  'core_ext/false_class',
  'core_ext/fixnum',
  'core_ext/float',
  'core_ext/string',
  'core_ext/true_class',
].each do |filename|
  require(File.expand_path("../../lib/crystal/#{filename}",  __FILE__))
end
