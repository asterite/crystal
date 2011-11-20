module Crystal
  class Visitor
    [
      'module',
      'expressions',
      'class',
      'bool',
      'int',
      'long',
      'float',
      'char',
      'add',
      'sub',
      'mul',
      'div',
      'def',
      'ref',
      'var',
      'call',
      'lt',
      'let',
      'eq',
      'gt',
      'get',
      'if',
      'static_if',
      'extern',
      'class_def',
      'assign',
      'while',
      'nil',
      'not',
      'and',
      'or',
      'block',
      'yield',
      'block_call',
      'block_reference',
      'return',
      'next',
      'break',
      'new_static_array',
      'static_array_set',
      'static_array_get',
      'alloc',
    ].each do |name|
      class_eval %Q(
        def visit_#{name}(node)
          true
        end

        def end_visit_#{name}(node)
        end
      )
    end
  end
end
