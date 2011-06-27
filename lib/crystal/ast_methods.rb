module Crystal
  class ASTNode
    def self.find_method(name)
      nil
    end
  end

  class Int
    def self.name; "Int"; end

    Methods = {}

    def self.binary_method(op, class_name, code)
      class_eval %Q(
        class #{class_name} < Def
          def initialize
            super "Int##{op}", [Var.new("x"), Var.new("y")], nil
          end

          def add_function_attributes(fun)
            fun.add_attribute :always_inline
          end

          def codegen_body(mod, fun)
            #{code}
          end
        end
        Methods[:"#{op}"] = #{class_name}
      )
    end

    [
      ["Add", "+", "add"],
      ["Sub", "-", "sub"],
      ["Mul", "*", "mul"],
      ["Div", "/", "sdiv"]
    ].each do |node, op, method|
      binary_method op, node, "mod.builder.#{method} fun.params[0], fun.params[1], '#{method}tmp'"
    end

    [
      ['LT', "<", "slt"],
      ['LET', "<=", "sle"],
      ['GT', ">", "sgt"],
      ['GET', ">=", "sge"],
      ['EQ', "==", "eq"],
    ].each do |node, op, method|
      binary_method op, node, %Q(
        cond = mod.builder.icmp :#{method}, fun.params[0], fun.params[1], '#{method}tmp'
        mod.builder.zext(cond, Crystal::DefaultType, 'booltmp')
      )
    end

    def self.find_method(name)
      method = Methods[name]
      method ? method.new : nil
    end
  end
end
