require 'vector_embed'

class VectorEmbed
  class Boolean
    def token(v)
      case v
      when TrueClass, 'true'
        1
      when FalseClass, 'false'
        -1 
      when NilClass, 'null'
        0
      else
        raise ArgumentError, "Can't embed #{v.inspect} in boolean mode."
      end
    end
  end
end
