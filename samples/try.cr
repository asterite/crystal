def foo
  yield 1
end

def bar
  foo do |x|
    yield x + 1
  end
end

def baz
  a = 10
  bar do |x|
    x + a
  end
end

puts baz
