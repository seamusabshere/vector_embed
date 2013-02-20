require 'vector_embed/maker'

require 'murmurhash3'

class VectorEmbed
  class Maker
    class Phrase < Maker
      class << self
        def want?(k, v, parent)
          true
        end
      end

      def value(v)
        v = parent.preprocess v.to_s
        MurmurHash3::V32.str_hash v
      end
    end
  end
end
