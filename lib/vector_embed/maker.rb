require 'vector_embed/maker/phrase'
require 'vector_embed/maker/ngram'
require 'vector_embed/maker/number'
require 'vector_embed/maker/boolean'

require 'murmurhash3'

class VectorEmbed
  class Maker
    class << self
      def pick(choices, k, first_v, parent)
        if klass = choices.detect { |klass| klass.want?(k, first_v, parent) }
          parent.logger.debug { "Interpreting #{k.inspect} as #{klass.name.split('::').last} given first value #{first_v.inspect}" }
          klass.new k, parent
        else
          raise "Can't use #{first_v.class} for #{k.inspect} given #{first_v.inspect} and choices #{choices.inspect}"
        end
      end

      def index(*parts)
        MurmurHash3::V32.str_hash(parts.join(NULL_BYTE)).to_s[0..6].to_i
      end
    end

    attr_reader :parent
    attr_reader :k

    def initialize(k, parent)
      @k = k
      @parent = parent
    end

    def pairs(v)
      case v
      when Array
        memo = []
        v.each_with_index do |vv, i|
          memo << [ Maker.index(k, i), value(vv) ]
        end
        memo
      else
        [ [ Maker.index(k), value(v) ] ]
      end
    end
  end
end
