def foo x
  yield x + 1
  yield x + 2
  yield x + 3
end

foo(10) do |x|
  puts x
end
