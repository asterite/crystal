class Int
  def fib
    if self <= 2
      1
    else
      (self - 1).fib + (self - 2).fib
    end
  end
end

puts 10.fib
