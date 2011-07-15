class Fixnum
  def int
    Crystal::Int.new self
  end

  def long
    Crystal::Long.new self
  end
end
