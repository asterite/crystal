def foo
  yield 1
end

val1 = foo do |x|
    x + 2
    end

val2 = foo do |x|
    x > 0
    end

puts val1
puts val2
