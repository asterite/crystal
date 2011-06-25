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
      nodes.each do |node|
        value = node.eval self
      end
      value
    end

    def eval(string)
      nodes = Parser.parse string
      return nil if nodes.empty?

      define *nodes
    end
  end
end
