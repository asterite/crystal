module Crystal
  class ASTNode
    def self.find_method(name)
      nil
    end
  end

  class Intrinsic < Def
    def initialize(name, args_length, &block)
      @name = name
      @args = args_length.times.map{|i| Var.new("x#{i}")}
      @block = block
    end

    def add_function_attributes(fun)
      fun.add_attribute :always_inline
    end

    def codegen_body(mod, fun)
      @block.call mod, fun
    end
  end

  class Int
    def self.name; "Int"; end

    Methods = {}
    def self.crystal_define_method(name, method)
      Methods[name] = method
    end

    def self.crystal_define_intrinsic(name, args_length, &block)
      Methods[name] = Intrinsic.new("#{self.name}##{name}", args_length, &block)
    end

    crystal_define_method 'class', Def.new("Int#class", [Var.new("self")], Int.new(object_id))

    [
      ['+', 'add'],
      ['-', 'sub'],
      ['*', 'mul'],
      ['/', 'sdiv'],
    ].each do |op, method|
      class_eval %Q(
        crystal_define_intrinsic(:'#{op}', 2) { |mod, fun| mod.builder.#{method} fun.params[0], fun.params[1], '#{method}tmp' }
      )
    end

    [
      ["<", "slt"],
      ["<=", "sle"],
      [">", "sgt"],
      [">=", "sge"],
      ["==", "eq"],
    ].each do |op, method|
      class_eval %Q(
        crystal_define_intrinsic(:'#{op}', 2) do |mod, fun|
          cond = mod.builder.icmp :#{method}, fun.params[0], fun.params[1], '#{method}tmp'
          mod.builder.zext(cond, Crystal::DefaultType, 'booltmp')
        end
      )
    end

    def self.find_method(name)
      method = Methods[name]
      method ? method.dup : nil
    end
  end
end
