module Crystal
  class ASTNode
    def compile(mod)
      mod.define_at_top_level self
    end

    def eval(mod)
      fun = compile mod
      mod.run fun
    end
  end

  class Expressions
    def compile(mod)
      last = nil
      expressions.each do |exp|
        last = exp.compile mod
        yield last if block_given? && last
      end
      last
    end

    def eval(mod)
      expressions.each { |exp| exp.eval mod }
    end
  end

  class Def
    def compile(mod)
      mod.add_expression self
      nil
    end

    def eval(mod)
      compile mod
      nil
    end
  end

  class ClassDef
    def compile(mod)
      resolve mod
      nil
    end
  end

  class Prototype
    def compile(mod)
      resolve mod
      codegen mod
      mod.add_c_expression self
      nil
    end

    def eval(mod)
      compile mod
    end
  end

  class TopLevelDef < Def
    def define_optimizations(fun)
      super
      fun.linkage = :private
    end
  end

  class Module
    def compile(string)
      exps = Parser.parse string
      exps.compile self
    end

    def eval(string)
      exps = Parser.parse string
      last = nil
      exps.compile self do |exp|
        last = run exp
      end
      last
    end
  end
end
