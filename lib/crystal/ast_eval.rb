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
      exps.expressions.each { |exp| last = exp.compile self }
      last
    end

    def eval(string)
      anon_def = compile string
      if anon_def
        run anon_def
      else
        nil
      end
    end
  end
end
