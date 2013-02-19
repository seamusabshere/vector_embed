require 'vector_embed/version'
require 'vector_embed/phrase'
require 'vector_embed/ngram'
require 'vector_embed/number'
require 'vector_embed/boolean'

require 'vector_embed/stop_word'

require 'digest/md5'

class VectorEmbed
  # http://stackoverflow.com/questions/638565/parsing-scientific-notation-sensibly
  JUST_A_NUMBER = /\A[+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?\z/
  BLANK = /\A\s*\z/

  attr_reader :options

  def initialize(options = {})
    @mutex = Mutex.new
    @feature_value_tokenizers = {}
    @options = options.dup
  end

  def line(label, features)
    label_token = label_token label
    feature_token_pairs = features.inject([]) do |memo, (k, v)|
      case v
      when Array
        v.each_with_index do |vv, i|
          memo.concat feature_token_pairs("#{k}_#{i}", vv)
        end
      else
        memo.concat feature_token_pairs(k, v)
      end
      memo
    end.compact.sort_by do |tok_k, tok_v|
      tok_k
    end.map do |pair|
      pair.join ':'
    end
    ([label_token] + feature_token_pairs).join ' '
  end

  def remove_stop_words(v)
    StopWord.remove stop_words, v
  end

  private

  def stop_words
    @stop_words ||= options.fetch(:stop_words, []).map do |raw_stop_word|
      StopWord.new raw_stop_word
    end
  end

  def label_token(v)
    label_tokenizer(v).token v
  end

  def feature_token_pairs(k, v)
    v_tokens = feature_value_tokenizer(k, v).token v
    case v_tokens
    when Array
      v_tokens.map do |vv|
        feature_token_pairs(vv, true)
      end
    else
      k_token = feature_key_tokenizer(k).token k
      [ [ k_token, v_tokens ] ]
    end
  end

  def label_tokenizer(v)
    @label_tokenizer || @mutex.synchronize do
      @label_tokenizer ||= pick_tokenizer(v)
    end
  end

  def feature_key_tokenizer(k)
    @feature_key_tokenizer || @mutex.synchronize do
      @feature_key_tokenizer ||= pick_tokenizer(k)
    end
  end

  def feature_value_tokenizer(k, v)
    @feature_value_tokenizers[k] || @mutex.synchronize do
      @feature_value_tokenizers[k] ||= pick_tokenizer(v, true)
    end
  end

  def pick_tokenizer(v, allow_ngram = false)
    case v
    when Numeric, JUST_A_NUMBER
      Number.new
    when NilClass, TrueClass, FalseClass, 'true', 'false', 'null'
      Boolean.new
    else
      if allow_ngram and options[:ngram_len]
        Ngram.new self
      else
        Phrase.new self
      end
    end
  end
end
