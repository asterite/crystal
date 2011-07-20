def times x
  if x > 0
    n = 0
    while n < x
      yield n
      n = n + 1
    end
  end
  x
end

times(5) { |x| puts x }
