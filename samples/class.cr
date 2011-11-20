class Foo
  def initialize(x)
    @x = x
  end

  def x
    @x
  end
end

f1 = Foo.new 1
f2 = Foo.new 2.0

puts(f1.x + f2.x)
