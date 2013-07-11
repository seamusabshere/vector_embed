require 'vector_embed/maker'

class VectorEmbed
  class Maker
    class Number < Maker
      class << self
        def want?(v, parent)
          case v
          when Numeric, NilClass, NULL, SLASH_N
            true
          when String
            v =~ JUST_A_NUMBER or v =~ UGLY_FLOAT
          end
        end

        def numify(v)
          num = if v.is_a?(String)
            if v.include?('.') or v.include?('e')
              v.to_f
            else
              v.to_i
            end
          else
            v
          end
        end
      end
      
      FORMAT = '%.16g'

      def value(v)
        case v
        when Numeric, JUST_A_NUMBER, UGLY_FLOAT
          num = Number.numify v
          if num.nonzero? or keep_zero?
            FORMAT % num
          end
        when NilClass, NULL, SLASH_N
          keep_zero? ? 0 : nil
        else
          raise ArgumentError, "Can't embed #{v.inspect} in number feature #{k.inspect}"
        end
      end

      def keep_zero?
        return @keep_zero_query if defined?(@keep_zero_query)
        @keep_zero = options && !!options[:keep_zero]
      end
    end
  end
end
