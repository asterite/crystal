module Crystal
  class Visitor
    [
      'module',
      'expressions',
      'class',
      'bool',
      'int',
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
      'prototype',
      'class_def',
      'assign',
      'while',
      'nil',
      'and',
      'or',
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
