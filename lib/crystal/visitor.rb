module Crystal
  class Visitor
    ['module', 'int', 'add', 'sub', 'mul', 'div', 'def', 'ref', 'arg', 'call'].each do |name|
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
