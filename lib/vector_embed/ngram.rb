require 'vector_embed'

require 'murmurhash3'

class VectorEmbed
  class Ngram
    attr_reader :len
    attr_reader :delim
    attr_reader :parent

    def initialize(parent)
      @len = parent.options[:ngram_len].to_i
      raise ArgumentError, ":ngram_len must be > 0" unless @len > 0
      @delim = parent.options[:ngram_delim]
      @parent = parent
    end

    def token(v)
      v = parent.remove_stop_words v.to_s
      ngrams = if len == 1
        # word mode
        v.split delim
      elsif delim == ''
        # byte mode
        (0..v.length-len).map { |i| v[i,len] }
      else
        raise RuntimeError, "Word n-gram not supported yet"
      end
      ngrams.map do |ngram|
        MurmurHash3::V32.str_hash "ngram_#{ngram.gsub(/\s/, '_')}"
      end
    end
  end
end
