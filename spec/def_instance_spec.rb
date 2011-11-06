require(File.expand_path("../../lib/crystal",  __FILE__))

describe "def instance" do
  it "adds a global method" do
    mod = Crystal::Module.new
    mod.eval "def foo; end"

    method = mod.find_method 'foo'
    method.should_not be_nil
    method.name.should eq('foo')
    method.args.should be_empty
  end

  it "adds a class method" do
    mod = Crystal::Module.new
    mod.eval "class Int; def foo; end; end"

    method = mod.int_class.find_method 'foo'
    method.should_not be_nil
    method.name.should eq('foo')
    method.args.should be_empty
  end

  it "adds a class method finds it in inherited" do
    mod = Crystal::Module.new
    mod.eval "class Number; def foo; end; end"

    method = mod.int_class.find_method 'foo'
    method.should_not be_nil
    method.name.should eq('foo')
    method.args.should be_empty
  end

  it "adds a static class method 1" do
    mod = Crystal::Module.new
    mod.eval "class Int; def self.foo; end; end"

    method = mod.int_class.metaclass.find_method 'foo'
    method.should_not be_nil
    method.name.should eq('foo')
    method.args.should be_empty
  end

  it "adds a static class method 2" do
    mod = Crystal::Module.new
    mod.eval "def Int.foo; end"

    method = mod.int_class.metaclass.find_method 'foo'
    method.should_not be_nil
    method.name.should eq('foo')
    method.args.should be_empty
  end

  it "adds a static class method finds it in inherited" do
    mod = Crystal::Module.new
    mod.eval "def Number.foo; end"

    method = mod.int_class.metaclass.find_method 'foo'
    method.should_not be_nil
    method.name.should eq('foo')
    method.args.should be_empty
  end

  it "adds a method to Class finds it in inherited" do
    mod = Crystal::Module.new
    mod.eval "class Class; def foo; end; end"

    method = mod.int_class.metaclass.find_method 'foo'
    method.should_not be_nil
    method.name.should eq('foo')
    method.args.should be_empty
  end

  it "adds an extern method as static method of C" do
    mod = Crystal::Module.new
    mod.eval "extern foo : Int"

    method = mod.c_class.metaclass.find_method 'foo'
    method.should_not be_nil
    method.name.should eq('foo')
    method.arg_types.should be_empty
  end

  it "instantiates a global method with no arguments" do
    mod = Crystal::Module.new
    mod.eval "def foo; 1; end"

    call = Crystal::Call.new nil, 'foo', []
    result = call.eval mod
    result.should eq(1.int)

    exp = mod.find_def_instance 'foo<>'
    exp.should_not be_nil
    exp.obj.should be_nil
    exp.resolved_type.should eq(mod.int_class)

    call.resolved.should eq(exp)
  end

  it "instantiates a global method with one argument" do
    mod = Crystal::Module.new
    result = mod.eval "def foo(x); x; end"

    call = Crystal::Call.new nil, 'foo', [1.int]
    result = call.eval mod
    result.should eq(1.int)

    exp = mod.find_def_instance 'foo<Int>'
    exp.should_not be_nil
    exp.obj.should be_nil
    exp.resolved_type.should eq(mod.int_class)
    exp.args[0].resolved_type.should eq(mod.int_class)

    call.resolved.should eq(exp)
  end

  it "instantiates a class method with no arguments" do
    mod = Crystal::Module.new
    mod.eval "class Int; def foo; 1; end; end"

    call = Crystal::Call.new 1.int, 'foo', []
    result = call.eval mod
    result.should eq(1.int)

    exp = mod.find_def_instance 'Int#foo<Int>'
    exp.should_not be_nil
    exp.obj.should eq(mod.int_class)
    exp.resolved_type.should eq(mod.int_class)
    exp.args.length.should eq(1)
    exp.args[0].should eq(Crystal::Var.new('self', mod.int_class))

    call.resolved.should eq(exp)
  end

  it "instantiates a class method with one argument" do
    mod = Crystal::Module.new
    mod.eval "class Int; def foo(x); x; end; end"

    call = Crystal::Call.new 1.int, 'foo', [1.int]
    result = call.eval mod
    result.should eq(1.int)

    exp = mod.find_def_instance 'Int#foo<Int, Int>'
    exp.should_not be_nil
    exp.obj.should eq(mod.int_class)
    exp.resolved_type.should eq(mod.int_class)
    exp.args.length.should eq(2)
    exp.args[0].should eq(Crystal::Var.new('self', mod.int_class))
    exp.args[1].should eq(Crystal::Var.new('x', mod.int_class))

    call.resolved.should eq(exp)
  end

  it "instantiates a class method with one argument 2", :focus => true do
    mod = Crystal::Module.new
    mod.eval "class Int; def foo(x); x + 2; end; end"

    call = Crystal::Call.new 1.int, 'foo', [1.int]
    result = call.eval mod
    result.should eq(3.int)
  end

  it "instantiates an inherited class method with no arguments" do
    mod = Crystal::Module.new
    mod.eval "class Number; def foo; 1; end; end"

    call = Crystal::Call.new 1.int, 'foo', []
    result = call.eval mod
    result.should eq(1.int)

    exp = mod.find_def_instance 'Number#foo<Int>'
    exp.should_not be_nil
    exp.obj.should eq(mod.number_class)
    exp.resolved_type.should eq(mod.int_class)
    exp.args.length.should eq(1)
    exp.args[0].should eq(Crystal::Var.new('self', mod.int_class))

    call.resolved.should eq(exp)
  end

  it "instantiates a static class method with no arguments" do
    mod = Crystal::Module.new
    mod.eval "def Int.foo; 1; end"

    call = Crystal::Call.new "Int".ref, 'foo', []
    result = call.eval mod
    result.should eq(1.int)

    exp = mod.find_def_instance 'Int:Class::foo<Int:Class>'
    exp.should_not be_nil
  end

  it "instantiates an inherited static class method with no arguments" do
    mod = Crystal::Module.new
    mod.eval "def Number.foo; 1; end"

    call = Crystal::Call.new "Int".ref, 'foo', []
    result = call.eval mod
    result.should eq(1.int)

    exp = mod.find_def_instance 'Number:Class::foo<Int:Class>'
    exp.should_not be_nil
  end
end
