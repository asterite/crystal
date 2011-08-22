class Fixnum
  def int
    Crystal::Int.new self
  end

  def float
    Crystal::Float.new self.to_f
  end

  def long
    Crystal::Long.new self
  end
end
