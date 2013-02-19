require 'vector_embed'

require 'murmurhash3'

class VectorEmbed
  class Phrase
    attr_reader :parent
    
    def initialize(parent)
      @parent = parent
    end

    def token(v)
      v = parent.remove_stop_words v.to_s
      MurmurHash3::V32.str_hash v
    end
  end
end
