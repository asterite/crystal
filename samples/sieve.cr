amount = 100

cells = Bool[amount]
amount.times do |n|
  cells[n] = true
end

2.upto(amount) do |n|
  next unless cells[n]

  (n * 2).step(amount, n) do |x|
    cells[x] = false
  end
end

amount.times do |n|
  cells[n] ? print '1' : print '0'
end
