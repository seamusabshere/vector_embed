require 'logger'
require 'murmurhash3'

require 'vector_embed/version'
require 'vector_embed/maker'

require 'vector_embed/stop_word'

class VectorEmbed
  # http://stackoverflow.com/questions/638565/parsing-scientific-notation-sensibly
  JUST_A_NUMBER = /\A\s*[+\-]?(?:0|[1-9]\d*)(?:\.\d*)?(?:[eE][+\-]?\d+)?\s*\z/
  UGLY_FLOAT = /\A\.\d+\z/
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

  attr_accessor :logger
  attr_reader :dict
  attr_reader :options

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
    sig = parts.join NULL_BYTE
    if dict
      dict[sig] || @mutex.synchronize do
        dict[sig] ||= begin
          k = parts[0]
          @feature_makers[k].cardinality += 1
          dict[sig] = dict.length + 1
        end
      end
    else
      MurmurHash3::V32.str_hash(sig).to_s[0..6].to_i
    end
  end

  def stats_report
    report = @feature_makers.map do |feature, maker|
      [feature, maker.class, maker.cardinality]
    end
    total_cardinality = report.inject(0) { |sum, row| sum += row[2]; sum }

    report.unshift %w{ Feature Class Cardinality }
    feature_width     = report.map { |row| row[0].to_s.length }.max
    class_width       = report.map { |row| row[1].to_s.length }.max
    cardinality_width = report.map { |row| row[2].to_s.length }.max

    report = report.map do |row|
      [
        row[0].to_s.ljust(feature_width),
        row[1].to_s.ljust(class_width),
        row[2].to_s.rjust(cardinality_width),
      ].join(' | ')
    end
    total_width = report.first.length
    report.insert(1, ''.ljust(total_width, '-'))
    report.push(total_cardinality.to_s.rjust(total_width))
    report.push('').join("\n")
  end

  private

  def stop_words
    @stop_words ||= options.fetch(:stop_words, []).map do |raw_stop_word|
      StopWord.new raw_stop_word
    end
  end

  def label_maker(label)
    @label_maker || @mutex.synchronize do
      @label_maker ||= Maker.pick(LABEL_MAKERS, 'label', label, self, keep_zero: true)
    end
  end

  def feature_maker(k, v)
    @feature_makers[k] || @mutex.synchronize do
      @feature_makers[k] ||= Maker.pick(FEATURE_MAKERS, k, v, self)
    end
  end
end
