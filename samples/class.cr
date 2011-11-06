class Stack
  def initialize
  end

  def set
    @coco = 1
  end

  def incr
    @coco = 10
  end

  def get
    @coco
  end
end

class Array
  def map(&block)
    ret = block.class[]
    each do |elem|
      ret << block.call(elem)
    end
    ret
  end
end

class String
  def initialize(initial = nil)
    @buffer = initial ? initial : Char[]
  end
end

a = [1, 2, 3]
b = a.map{|x| x > 2}
