require 'vector_embed'

class VectorEmbed
  class StopWord
    class << self
      def remove(stop_words, str)
        memo = str.dup
        stop_words.each do |stop_word|
          stop_word.apply! memo
        end
        memo.gsub! /\s+/, ' '
        memo.strip!
        memo
      end
    end

    def initialize(raw_stop_word)
      @pattern = /\s*\b#{raw_stop_word}\b\s*/i
    end
    def apply!(str)
      str.gsub! @pattern, ' '
    end
  end
end
