require 'vector_embed/maker/phrase'
require 'vector_embed/maker/ngram'
require 'vector_embed/maker/number'
require 'vector_embed/maker/boolean'
require 'vector_embed/maker/date'

class VectorEmbed
  class Maker
    class << self
      def pick(choices, k, first_v, parent)
        if (feature_types = parent.options[:features]) and (type = feature_types.detect { |kk, v| kk.to_s == k.to_s })
          klass = const_get type[1].to_sym
          klass.new k, parent
        elsif klass = choices.detect { |klass| klass.want?(first_v, parent) }
          parent.logger.debug { "Interpreting #{k.inspect} as #{klass.name.split('::').last} given first value #{first_v.inspect}" }
          klass.new k, parent
        else
          raise "Can't use #{first_v.class} for #{k.inspect} given #{first_v.inspect} and choices #{choices.inspect}"
        end
      end
    end

    attr_accessor :cardinality
    attr_reader :parent
    attr_reader :k

    def initialize(k, parent)
      @k = k
      @parent = parent
      @cardinality = 0
    end

    def pairs(v)
      case v
      when Array
        memo = []
        v.each_with_index do |vv, i|
          unless (vvv = value(vv)).nil?
            memo << [ parent.index([k, i]), vvv ]
          end
        end
        memo
      else
        if (vv = value(v)).nil?
          []
        else
          [ [ parent.index([k]), vv ] ]
        end
      end
    end
  end
end
