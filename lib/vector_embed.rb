require 'logger'
require 'digest/md5'
require 'murmurhash3'

require 'vector_embed/version'
require 'vector_embed/maker'

require 'vector_embed/stop_word'

class VectorEmbed
  # http://stackoverflow.com/questions/638565/parsing-scientific-notation-sensibly
  JUST_A_NUMBER = /\A\s*[+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?\s*\z/
  BLANK = /\A\s*\z/
  NULL = /\Anull\z/i
  SLASH_N = '\N'
  TRUE = /\Atrue\z/i
  T = /\At\z/i
  FALSE = /\Afalse\z/i
  F = /\Af\z/i
  NULL_BYTE = "\x00"
  LABEL_MAKERS =   [Maker::Boolean, Maker::Number]
  FEATURE_MAKERS = [Maker::Boolean, Maker::Date, Maker::Number, Maker::Ngram, Maker::Phrase]

  attr_reader :options
  attr_accessor :logger
  attr_reader :dict

  def initialize(options = {})
    @options = options.dup
    @mutex = Mutex.new
    @feature_makers = {}
    @logger = options[:logger] || (l = Logger.new($stderr); l.level = (ENV['VERBOSE'] == 'true') ? Logger::DEBUG : Logger::INFO; l)
    if dict = @options.delete(:dict)
      @dict = dict.dup
    end
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

  def index(parts)
    k = parts.join NULL_BYTE
    if dict
      k = Digest::MD5.digest k
      dict[k] || @mutex.synchronize do
        dict[k] ||= dict.length + 1
      end
    else
      MurmurHash3::V32.str_hash(k).to_s[0..6].to_i
    end
  end

  private

  def stop_words
    @stop_words ||= options.fetch(:stop_words, []).map do |raw_stop_word|
      StopWord.new raw_stop_word
    end
  end

  def label_maker(label)
    @label_maker || @mutex.synchronize do
      @label_maker ||= Maker.pick(LABEL_MAKERS, 'label', label, self)
    end
  end

  def feature_maker(k, v)
    @feature_makers[k] || @mutex.synchronize do
      @feature_makers[k] ||= Maker.pick(FEATURE_MAKERS, k, v, self)
    end
  end
end
