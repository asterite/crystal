def foo
  yield 1, 2
end

def bar(x, y)
  14 * (x + y)
end

foo do |x, y|
  puts bar(x, y)
end
