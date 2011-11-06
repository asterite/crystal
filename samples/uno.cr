class Int
  def foo
    true
  end

  def bar
    1.upto 3 do |x|
      return false if foo
    end
    true
  end
end

puts 1.bar
