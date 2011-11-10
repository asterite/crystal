max = 100

cells = Bool[max]
max.times do |n|
  cells[n] = true
end

2.upto(Math.sqrt(max).to_i) do |n|
  next unless cells[n]

  (n * 2).step(max, n) do |x|
    cells[x] = false
  end
end

found = false
2.upto(max) do |n|
  if cells[n]
    if found
      print ','
      print ' '
    else
      found = true
    end
    print n
  end
end
