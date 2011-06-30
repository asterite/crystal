module Crystal
  class ASTNode
    def compile(mod)
      mod.define_at_top_level self
    end
  end

  class Def
    def compile(mod)
      mod.add_expression self
      nil
    end
  end

  class TopLevelDef < Def
    def optimize(fun)
      fun.linkage = :private
    end
  end

  class Module
    def compile(string)
      exps = Parser.parse string
      last = nil
      exps.expressions.each do|exp|
        last = exp.compile self
      end
      last
    end

    def eval(string)
      exps = Parser.parse string
      last = nil
      exps.expressions.each do |exp|
        last = exp.compile self
        if last
          last = run last
        end
      end
      last
    end
  end
end
