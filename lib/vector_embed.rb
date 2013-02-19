require 'vector_embed/version'
require 'vector_embed/phrase'
require 'vector_embed/number'
require 'vector_embed/boolean'

require 'digest/md5'

class VectorEmbed
  class << self
    def pick_tokenizer(v)
      case v
      when Numeric, JUST_A_NUMBER
        Number.new
      when NilClass, TrueClass, FalseClass, 'true', 'false', 'null'
        Boolean.new
      else
        Phrase.new
      end
    end
  end

  # http://stackoverflow.com/questions/638565/parsing-scientific-notation-sensibly
  JUST_A_NUMBER = /\A[+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?\z/
  BLANK = /\A\s*\z/

  def initialize
    @mutex = Mutex.new
    @feature_value_tokenizers = {}
  end

  def line(label, features)
    label_token = label_token label
    feature_token_pairs = features.inject([]) do |memo, (k, v)|
      case v
      when Array
        v.each_with_index do |vv, i|
          memo << feature_token_pair("#{k}_#{i}", vv)
        end
      else
        memo << feature_token_pair(k, v)
      end
      memo
    end.compact.sort_by do |tok_k, tok_v|
      tok_k
    end.map do |pair|
      pair.join ':'
    end
    ([label_token] + feature_token_pairs).join ' '
  end

  private

  def label_token(v)
    label_tokenizer(v).token v
  end

  def feature_token_pair(k, v)
    k_token = feature_key_tokenizer(k).token k
    v_token = feature_value_tokenizer(k, v).token v
    [ k_token, v_token ]
  end

  def label_tokenizer(v)
    @label_tokenizer || @mutex.synchronize do
      @label_tokenizer ||= VectorEmbed.pick_tokenizer(v)
    end
  end

  def feature_key_tokenizer(k)
    @feature_key_tokenizer || @mutex.synchronize do
      @feature_key_tokenizer ||= VectorEmbed.pick_tokenizer(k)
    end
  end

  def feature_value_tokenizer(k, v)
    @feature_value_tokenizers[k] || @mutex.synchronize do
      @feature_value_tokenizers[k] ||= VectorEmbed.pick_tokenizer(v)
    end
  end
end
