module Crystal
  class ASTNode
    def compile(scope)
      scope.define_at_top_level self
    end

    def eval(scope)
      fun = compile scope
      scope.run fun
    end
  end

  class Expressions
    def compile(scope)
      last = nil
      expressions.each do |exp|
        last = exp.compile scope
        yield last if block_given? && last
      end
      last
    end

    def eval(scope)
      expressions.each { |exp| exp.eval scope }
    end
  end

  class Def
    def compile(scope)
      if receiver
        receiver.resolve scope
        receiver.resolved.metaclass.define_method self
      else
        scope.define_method self
      end
      nil
    end

    def eval(scope)
      compile scope
      nil
    end
  end

  class ClassDef
    def compile(scope)
      resolve scope
      nil
    end
  end

  class Extern
    def compile(scope)
      resolve scope
      codegen scope
      scope.c_class.metaclass.define_method self
      nil
    end

    def eval(scope)
      compile scope
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
