module Crystal
  class ASTNode
    def eval(mod)
      anon_def = Def.new "", [], [self]
      anon_def.resolve mod
      anon_def.codegen mod
      #mod.module.dump
      mod.run anon_def.code
    end
  end

  class Def
    def eval(mod)
      mod.add_expression self
      nil
    end
  end

  class Module
    def define(*nodes)
      value = nil
      nodes.each { |node| value = node.eval self }
      value
    end

    def eval(string)
      exps = Parser.parse string

      define *exps.expressions
    end
  end
end
