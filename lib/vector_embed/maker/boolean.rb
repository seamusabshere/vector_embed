require 'vector_embed/maker'

class VectorEmbed
  class Maker
    class Boolean < Maker
      class << self
        def want?(k, v, parent)
          case v
          when NilClass, TrueClass, FalseClass, 'true', 'false', 'null'
            true
          else
            false
          end
        end
      end

      def value(v)
        case v
        when TrueClass, 'true', 't', 'yes', 'on'
          1
        when FalseClass, 'false', 'f', 'no', 'off'
          0
        else
          raise "Can't embed #{v.inspect} in boolean mode"
        end
      end

      def pairs(v)
        case v
        when TrueClass, 'true', 't', 'yes', 'on'
          [ [ Maker.index(k, 'true'), 1 ] ]
        when FalseClass, 'false', 'f', 'no', 'off'
          [ [ Maker.index(k, 'false'), 1 ] ]
        when NilClass, 'null', BLANK
          [ [ Maker.index(k, 'null'), 1 ] ]
        else
          raise ArgumentError, "Can't embed #{v.inspect} in boolean mode."
        end
      end
    end
  end
end
