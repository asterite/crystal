class Int
  def divisible_by?(num)
    self % num == 0
  end

  def prime?
    2.upto(self - 1) do |x|
      return false if divisible_by?(x)
    end
    true
  end
end

1.upto 10000 do |x|
  puts x if x.prime?
end
