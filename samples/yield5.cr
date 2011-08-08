def foo
  yield 7
end

def bar
  a = 5
  b = 9
  c = 0
  d = foo do |x|
    c = a + b + x
  end
  c + d
end

puts bar
