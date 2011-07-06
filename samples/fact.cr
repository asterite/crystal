def fact n
  if n <= 1
    1
  else
    n * fact(n - 1)
  end
end

C.puti fact(4)
