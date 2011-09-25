module Crystal
  class Token
    attr_accessor :type
    attr_accessor :value
    attr_accessor :line_number

    def to_s
      case type
      when :VAR
        "@#{value}"
      else
        value || type
      end
    end
  end
end
