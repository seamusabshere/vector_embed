require 'vector_embed/version'
require 'vector_embed/maker'

require 'vector_embed/stop_word'

class VectorEmbed
  # http://stackoverflow.com/questions/638565/parsing-scientific-notation-sensibly
  JUST_A_NUMBER = /\A\s*[+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?\s*\z/
  BLANK = /\A\s*\z/
  NULL_BYTE = "\x00"

  attr_reader :options

  def initialize(options = {})
    @mutex = Mutex.new
    @feature_makers = {}
    @options = options.dup
  end

  def line(label, features = {})
    feature_pairs = features.inject([]) do |memo, (k, v)|
      case v
      when Array
        v.each_with_index do |vv, i|
          memo.concat feature_maker([k, i].join(NULL_BYTE), vv).pairs(vv)
        end
      else
        memo.concat feature_maker(k, v).pairs(v)
      end
      memo
    end.compact.sort_by do |k_value, _|
      k_value
    end.map do |pair|
      pair.join ':'
    end
    ([label_maker(label).value(label)] + feature_pairs).join ' '
  end

  def preprocess(v)
    StopWord.remove stop_words, v
  end

  private

  def stop_words
    @stop_words ||= options.fetch(:stop_words, []).map do |raw_stop_word|
      StopWord.new raw_stop_word
    end
  end

  def label_maker(label)
    @label_maker || @mutex.synchronize do
      @label_maker ||= Maker.pick([Maker::Boolean, Maker::Number], 'label', label, self)
    end
  end

  def feature_maker(k, v)
    @feature_makers[k] || @mutex.synchronize do
      @feature_makers[k] ||= Maker.pick([Maker::Boolean, Maker::Number, Maker::Ngram, Maker::Phrase], k, v, self)
    end
  end
end
