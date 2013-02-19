require 'vector_embed'

class VectorEmbed
  class Continuous
    class << self
      def numify(v)
        num = if v.is_a?(String)
          v.include?('.') ? v.to_f : v.to_i
        else
          v
        end
        num > 99_999 ? ('%e' % num) : num
      end
    end

    def token(v)
      case v
      when NilClass, BLANK
        0
      when TrueClass
        1
      when FalseClass
        -1 
      when Numeric, JUST_A_NUMBER
        Continuous.numify v
      else
        raise ArgumentError, "Can't embed string #{v.inspect} after continuous (numeric/boolean) values already embedded."
      end
    end
  end
end
