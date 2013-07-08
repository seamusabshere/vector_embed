require 'vector_embed/maker'

class VectorEmbed
  class Maker
    class Ngram < Maker
      class << self
        def want?(v, parent)
          parent.options[:ngram_len]
        end
      end

      attr_reader :len
      attr_reader :delim

      def initialize(k, parent)
        super
        @len = parent.options[:ngram_len].to_i
        raise ArgumentError, ":ngram_len must be > 0" unless @len > 0
        @delim = parent.options[:ngram_delim]
      end

      def pairs(v)
        raise "Ngram can't handle #{v.inspect}, only a single string for now" unless v.is_a?(::String)
        v = parent.preprocess v.to_s
        if len == 1
          # word mode
          v.split delim
        elsif delim == ''
          # byte mode
          (0..v.length-len).map { |i| v[i,len] }
        else
          raise "Word n-gram not supported yet"
        end.map do |ngram|
          [ parent.index([k, 'ngram', ngram]), 1 ]
        end
      end
    end
  end
end
