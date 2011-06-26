module Crystal
  class ASTNode
    def self.find_method(name)
      nil
    end
  end

  class Int
    Methods = {}

    [
      ["Add", "+", "add"],
      ["Sub", "-", "sub"],
      ["Mul", "*", "mul"],
      ["Div", "/", "sdiv"]
    ].each do |node, op, method|
      class_eval %Q(
        class #{node} < Def
          def initialize
            super "Crystal::Int##{op}", [Var.new("x"), Var.new("y")], nil
          end

          def codegen_body(mod, fun)
            mod.builder.#{method} fun.params[0], fun.params[1], '#{method}tmp'
          end
        end
        Methods[:"#{op}"] = #{node}
      )
    end

    [
      ['LT', "<", "slt"],
      ['LET', "<=", "sle"],
      ['GT', ">", "sgt"],
      ['GET', ">=", "sge"],
      ['EQ', "==", "eq"],
    ].each do |node, op, method|
      class_eval %Q(
        class #{node} < Def
          def initialize
            super "Crystal::Int##{op}", [Var.new("x"), Var.new("y")], nil
          end

          def codegen_body(mod, fun)
            cond = mod.builder.icmp :#{method}, fun.params[0], fun.params[1], '#{method}tmp'
            mod.builder.zext(cond, Crystal::DefaultType, 'booltmp')
          end
        end
        Methods[:"#{op}"] = #{node}
      )
    end

    def self.find_method(name)
      method = Methods[name]
      if method
        method.new
      else
        nil
      end
    end
  end

end
