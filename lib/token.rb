class Token
  attr_accessor :type
  attr_accessor :value

  def to_s
    value || type
  end
end
