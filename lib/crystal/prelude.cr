class Object
end

class Class
  extern crystal_class_object_id Class #=> Long
  def object_id
    C.crystal_class_object_id self
  end

  def ==(other)
    self.object_id == other.object_id
  end
end

class Bool
  extern crystal_eq_bool Bool, Bool #=> Bool
  def ==(other)
    C.crystal_eq_bool self, other
  end
end

class Int
  extern crystal_add_int_int Int, Int #=> Int
  extern crystal_add_int_float Int, Float #=> Float
  def +(other)
    If other.class == Int
      C.crystal_add_int_int self, other
    Elsif other.class == Float
      C.crystal_add_int_float self, other
    End
  end

  extern crystal_sub_int_int Int, Int #=> Int
  extern crystal_sub_int_float Int, Float #=> Float
  def -(other)
    If other.class == Int
      C.crystal_sub_int_int self, other
    Elsif other.class == Float
      C.crystal_sub_int_float self, other
    End
  end

  extern crystal_mul_int_int Int, Int #=> Int
  extern crystal_mul_int_float Int, Float #=> Float
  def *(other)
    If other.class == Int
      C.crystal_mul_int_int self, other
    Elsif other.class == Float
      C.crystal_mul_int_float self, other
    End
  end

  extern crystal_div_int_int Int, Int #=> Int
  extern crystal_div_int_float Int, Float #=> Float
  def /(other)
    If other.class == Int
      C.crystal_div_int_int self, other
    Elsif other.class == Float
      C.crystal_div_int_float self, other
    End
  end

  extern crystal_lt_int_int Int, Int #=> Bool
  extern crystal_lt_int_float Int, Float #=> Bool
  def <(other)
    If other.class == Int
      C.crystal_lt_int_int self, other
    Elsif other.class == Float
      C.crystal_lt_int_float self, other
    End
  end

  extern crystal_let_int_int Int, Int #=> Bool
  extern crystal_let_int_float Int, Float #=> Bool
  def <=(other)
    If other.class == Int
      C.crystal_let_int_int self, other
    Elsif other.class == Float
      C.crystal_let_int_float self, other
    End
  end

  extern crystal_eq_int_int Int, Int #=> Bool
  extern crystal_eq_int_float Int, Float #=> Bool
  def ==(other)
    If other.class == Int
      C.crystal_eq_int_int self, other
    Elsif other.class == Float
      C.crystal_eq_int_float self, other
    End
  end

  def >(other)
    If other.class == Int
      C.crystal_lt_int_int other, self
    Elsif other.class == Float
      C.crystal_lt_float_int other, self
    End
  end

  def >=(other)
    If other.class == Int
      C.crystal_let_int_int other, self
    Elsif other.class == Float
      C.crystal_let_float_int other, self
    End
  end

  def +@
    self
  end

  def -@
    0 - self
  end
end

class Long
  extern crystal_eq_long_long Long, Long #=> Bool
  def ==(other)
    C.crystal_eq_long_long self, other
  end
end

class Float
  extern crystal_add_float_float Float, Float #=> Float
  def +(other)
    If other.class == Int
      C.crystal_add_int_float other, self
    Elsif other.class == Float
      C.crystal_add_float_float self, other
    End
  end

  extern crystal_sub_float_float Float, Float #=> Float
  extern crystal_sub_float_int Float, Int #=> Float
  def -(other)
    If other.class == Int
      C.crystal_sub_float_int self, other
    Elsif other.class == Float
      C.crystal_sub_float_float self, other
    End
  end

  extern crystal_mul_float_float Float, Float #=> Float
  def *(other)
    If other.class == Int
      C.crystal_mul_int_float other, self
    Elsif other.class == Float
      C.crystal_mul_float_float self, other
    End
  end

  extern crystal_div_float_float Float, Float #=> Float
  extern crystal_div_float_int Float, Int #=> Float
  def /(other)
    If other.class == Int
      C.crystal_div_float_int self, other
    Elsif other.class == Float
      C.crystal_div_float_float self, other
    End
  end

  extern crystal_lt_float_float Float, Float #=> Bool
  extern crystal_lt_float_int Float, Int #=> Bool
  def <(other)
    If other.class == Int
      C.crystal_lt_float_int self, other
    Elsif other.class == Float
      C.crystal_lt_float_float self, other
    End
  end

  extern crystal_let_float_float Float, Float #=> Bool
  extern crystal_let_float_int Float, Int #=> Bool
  def <=(other)
    If other.class == Int
      C.crystal_let_float_int self, other
    Elsif other.class == Float
      C.crystal_let_float_float self, other
    End
  end

  extern crystal_eq_float_float Float, Float #=> Bool
  def ==(other)
    If other.class == Int
      C.crystal_eq_int_float other, self
    Elsif other.class == Float
      C.crystal_eq_float_float self, other
    End
  end

  def >(other)
    If other.class == Int
      C.crystal_lt_int_float other, self
    Elsif other.class == Float
      C.crystal_lt_float_float other, self
    End
  end

  def >=(other)
    If other.class == Int
      C.crystal_let_int_float other, self
    Elsif other.class == Float
      C.crystal_let_float_float other, self
    End
  end

  def +@
    self
  end

  def -@
    0 - self
  end
end

extern putb Bool #=> Nil
extern puti Int #=> Nil
extern putf Float #=> Nil
extern putchari Int #=> Nil
extern putcharf Float #=> Nil

def puts x
  If x.class == Bool
    C.putb x
  Elsif x.class == Int
    C.puti x
  Elsif x.class == Float
    C.putf x
  End
end

def putchar x
  If x.class == Int
    C.putchari x
  Elsif x.class == Float
    C.putcharf x
  End
end
