class String
  def arg
    Crystal::Arg.new self
  end

  def ref
    Crystal::Ref.new self
  end
end
