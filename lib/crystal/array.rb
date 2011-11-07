module Crystal
  class NewStaticArray < Expression
    def accept(visitor)
      visitor.visit_new_static_array self
      visitor.end_visit_new_static_array self
    end

    def ==(other)
      other.is_a?(NewStaticArray)
    end

    def clone
      NewStaticArray.new
    end
  end

  class StaticArraySet < Expression
    def accept(visitor)
      visitor.visit_static_array_set self
      visitor.end_visit_static_array_set self
    end

    def ==(other)
      other.is_a?(StaticArraySet)
    end

    def clone
      StaticArraySet.new
    end
  end

  class StaticArrayGet < Expression
    def accept(visitor)
      visitor.visit_static_array_get self
      visitor.end_visit_static_array_get self
    end

    def ==(other)
      other.is_a?(StaticArrayGet)
    end

    def clone
      StaticArrayGet.new
    end
  end
end
