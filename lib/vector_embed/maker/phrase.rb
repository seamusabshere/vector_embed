require 'vector_embed/maker'

class VectorEmbed
  class Maker
    class Phrase < Maker
      class << self
        def want?(k, v, parent)
          true
        end
      end

      def pairs(v)
        v = parent.preprocess v.to_s
        [ [ Maker.index(k, v), 1 ] ]
      end
    end
  end
end
