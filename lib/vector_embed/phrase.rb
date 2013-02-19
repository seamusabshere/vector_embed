require 'vector_embed'

require 'murmurhash3'

class VectorEmbed
  class Phrase
    def token(v)
      MurmurHash3::V32.str_hash v.to_s
    end
  end
end
