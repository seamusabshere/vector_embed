require 'vector_embed/maker'

class VectorEmbed
  class Maker
    class Boolean < Maker
      class << self
        def want?(k, v, parent)
          case v
          when NilClass, TrueClass, FalseClass, TRUE, FALSE, T, F, NULL, SLASH_N
            true
          else
            false
          end
        end
      end

      def value(v)
        case v
        when TrueClass, TRUE, T
          1
        when FalseClass, FALSE, F
          0
        else
          raise "Can't embed #{v.inspect} in boolean feature #{k.inspect}"
        end
      end

      def pairs(v)
        case v
        when TrueClass, TRUE, T
          [ [ Maker.index(k, 'true'), 1 ] ]
        when FalseClass, FALSE, F
          [ [ Maker.index(k, 'false'), 1 ] ]
        when NilClass, NULL, SLASH_N, BLANK
          [ [ Maker.index(k, 'null'), 1 ] ]
        else
          raise ArgumentError, "Can't embed #{v.inspect} in boolean feature #{k.inspect}"
        end
      end
    end
  end
end
