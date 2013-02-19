require 'vector_embed'

class VectorEmbed
  class Number
    class << self
      def numify(v)
        num = if v.is_a?(String)
          v.include?('.') ? v.to_f : v.to_i
        else
          v
        end
        num > 1e12 ? ('%.10e' % num) : num
      end
    end

    def token(v)
      case v
      when Numeric, JUST_A_NUMBER
        Number.numify v
      else
        raise ArgumentError, "Can't embed #{v.inspect} in number mode."
      end
    end
  end
end
