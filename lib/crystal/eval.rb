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
        name = self.name
        self.name = "#{receiver.resolved.name}::#{name}"
        self.args.insert 0, Var.new("self")
        self.args_length = self.args.length - 1
        receiver.resolved.define_static_method name, self, scope.class_class
      else
        scope.add_expression self
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

  class Prototype
    def compile(scope)
      resolve scope
      codegen scope
      scope.add_c_expression self
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
