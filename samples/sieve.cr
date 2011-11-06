max = 100

cells = Bool[max]
max.times do |n|
  cells[n] = true
end

2.upto(max) do |n|
  next unless cells[n]

  (n * 2).step(max, n) do |x|
    cells[x] = false
  end
end

max.times do |n|
  print n
  print ':'
  print ' '
  cells[n] ? puts('X') : puts(' ')
end
