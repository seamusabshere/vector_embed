require 'vector_embed'

class VectorEmbed
  class Dictionary
    def initialize
      @data = []
    end

    def token(v)
      md5 = Digest::MD5.digest v.to_s
      unless @data.include? md5
        @data << md5
      end
      @data.index(md5) + 1
    end
  end
end
