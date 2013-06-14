require 'vector_embed/maker'
require 'date'

class VectorEmbed
  class Maker
    class Date < Maker
      class << self
        def want?(v, parent)
          v.is_a?(::Date)
        end
      end

      BASE = ::Date.new(2000,1,1)
      BLANK = /\A\s*\z/

      def value(v)
        date = case v
        when ::String
          if v !~ BLANK
            ::Date.parse v
          end
        when ::Date
          v
        else
          raise "Can't embed #{v.inspect} in date feature #{k.inspect}"
        end
        if date
          num = (date - BASE).to_i
          if num.nonzero?
            num
          end
        end
      end
    end
  end
end
