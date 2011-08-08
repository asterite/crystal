def foo
  yield 11
end

def bar
  a = 31
  foo do |x|
    a + x
  end
end

puts bar
