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

  class DefScope < Scope
    attr_accessor :def

    def initialize(scope, a_def)
      @scope = scope
      @def = a_def
    end

    def add_expression(node)
      if @def.is_a?(TopLevelDef) || node.is_a?(Def) || node.is_a?(Prototype)
        @scope.add_expression node
      else
        @def.local_variables[node.name] = node
      end
    end

    def find_expression(name)
      local = find_local_expression(name)
      return local if local

      self.next.find_expression name
    end

    def find_variable(name)
      local = find_local_expression(name)
      return local if local

      self.next.find_variable name
    end

    def find_local_expression(name)
      arg = @def.args.select{|arg| arg.name == name}.first
      return arg if arg

      @def.local_variables[name]
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

    def add_expression(node)
      name = node.name
      node.name = "#{@class.name}##{name}"
      node.args.insert 0, Var.new("self")
      node.args_length = node.args.length - 1
      @class.define_method name, node
    end

    def find_expression(name)
      if name == 'self'
        return @class
      end
      super
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

    def find_expression(name)
      node = @context.find_expression name
      return node if node

      node = self.next.find_expression name
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

    def find_expression(name)
      result = @references[name]
      return result if result

      node = @scope.find_local_expression name
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
    def find_variable(name)
      nil
    end

    def returns!(a_def)
    end
  end
end
