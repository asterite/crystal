module Crystal
  class Scope
    def next
      @scope
    end

    def parent
      @scope
    end

    def is_block?
      false
    end

    def method_missing(name, *args)
      @scope.send name, *args
    end
  end

  class Module
    def define_method(method)
      @methods[method.name] = method
    end

    def find_class(name)
      @classes[name]
    end

    def find_method(name)
      @methods[name]
    end

    def define_local_var(var)
      @local_vars[var.name] = var
    end

    def find_local_var(name)
      @local_vars[name]
    end
  end

  class DefScope < Scope
    attr_accessor :def

    def initialize(scope, a_def)
      @scope = scope
      @def = a_def
    end

    def define_local_var(var)
      if @def.is_a?(TopLevelDef)
        @scope.define_local_var var
      else
        @def.local_vars[var.name] = var
      end
    end

    def find_local_var(name)
      if @def.is_a?(TopLevelDef)
        @scope.find_local_var name
      else
        exp = find_local_var_non_recursive name
        exp = self.next.find_local_var(name) if !exp && is_block?
        exp
      end
    end

    def find_method(name)
      if @def.obj
        exp = @def.obj.find_method name
        return exp if exp
      end

      self.next.find_method(name)
    end

    def find_local_var_non_recursive(name)
      @def.args.select{|arg| arg.name == name}.first || @def.local_vars[name]
    end

    def next
      tentative = @scope
      tentative = tentative.parent while tentative.is_a? DefScope
      tentative
    end

    def is_block?
      @def.is_block?
    end

    def returns!(a_def)
      parent.returns! a_def if is_block?
    end

    def def_not_block
      self.next.def_not_block
    end

    def to_s
      "Def<#{@def.name}(#{@def.args.map &:name})> -> #{@scope.to_s}"
    end
    alias inspect to_s
  end

  class ClassDefScope < Scope
    def initialize(scope, a_class)
      @scope = scope
      @class = a_class
    end

    def find_local_var(name)
      name == 'self' ? @class : nil
    end

    def define_method(method)
      @class.define_method method
    end

    def to_s
      "Class<#{@class.name}> -> #{@scope.to_s}"
    end
    alias inspect to_s
  end

  class BlockScope < Scope
    attr_accessor :context

    def initialize(scope, context)
      @scope = scope
      @context = context
    end

    def find_local_var(name)
      node = @context.find_local_var name
      return node if node

      node = self.next.find_local_var name
      if node.is_a? BlockReference
        @context.parent = self.next.context
        node.context = @context
      end
      node
    end

    def next
      tentative = @scope.parent
      while true
        break if tentative.is_a?(DefScope) && tentative.def.name == name
        tentative = tentative.parent
      end
      tentative.parent
    end

    def name
      @context.scope.def.name
    end

    def returns!(a_def)
      @context.returns!(a_def)
      self.next.returns!(a_def)
    end

    def def_not_block
      @context.scope.def
    end

    def to_s
      "Block<#{name}> -> #{self.next.to_s}"
    end
  end

  class BlockContext
    attr_accessor :parent

    def initialize(scope)
      @scope = scope
      @references = {}
    end

    def find_local_var(name)
      result = @references[name]
      return result if result

      node = @scope.find_local_var_non_recursive name
      if node
        node = BlockReference.new self, node
        @references[name] = node
      end
      node
    end

    def returns!(a_def)
      @return_def = a_def
    end

    def returns?
      !!@return_def
    end

    def return_type
      @return_def.resolved_type
    end
  end

  class Module
    def returns!(a_def)
    end
  end
end
