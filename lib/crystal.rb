[
  'ast',
  'ast_codegen',
  'ast_eval',
  'ast_methods',
  'ast_resolve',
  'ast_to_s',
  'lexer',
  'parser',
  'token',
  'visitor',
  'core_ext/fixnum',
  'core_ext/string',
].each do |filename|
  require(File.expand_path("../../lib/crystal/#{filename}",  __FILE__))
end
