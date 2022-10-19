module CLI
  struct Value
    alias Type = String | Number::Primitive | Bool | Nil # | Array(Type)

    getter raw : Type

    def initialize(@raw : Type)
    end

    def to_s(io : IO) : Nil
      @raw.to_s io
    end

    def size : Int32
      case value = @raw
      when Array
        value.size
      when Hash
        value.size
      else
        raise "Cannot get size of type #{value.class}"
      end
    end

    def ==(other : Type) : Bool
      @raw == other
    end

    def as_s : String
      @raw.as(String)
    end

    def as_i : Int
      @raw.to_s.to_i
    end

    def as_f : Float
      @raw.to_s.to_f
    end

    def as_bool : Bool
      if @raw.is_a? Bool
        @raw.as(Bool)
      else
        case @raw.to_s
        when "true"   then true
        when "false"  then false
        else
          raise TypeCastError.new "cast from #{@raw.class} to Bool failed"
        end
      end
    end

    def as_nil : Nil
      @raw.as(Nil)
    end

    def as_a : Array(Type)
      @raw.as(Array)
    end

    {% for base in %w(8 16 32 64 128) %}
    def as_i{{ base.id }} : Int{{ base.id }}
      @raw.as(Int{{ base.id }}).to_i{{ base.id }}
    end

    def as_i{{ base.id }}? : Int{{ base.id }}?
      @raw.as?(Int{{ base.id }}).try &.to_i{{ base.id }}?
    end

    def as_u{{ base.id }} : UInt{{ base.id }}
      @raw.as(UInt{{ base.id }}).to_u{{ base.id }}
    end

    def as_u{{ base.id }}? : UInt{{ base.id }}?
      @raw.as?(UInt{{ base.id }}).try &.to_u{{ base.id }}?
    end
    {% end %}

    {% for base in %w(32 64) %}
    def as_f{{ base.id }} : Float{{ base.id }}
      @raw.as(Float{{ base.id }}).to_f{{ base.id }}
    end

    def as_f{{ base.id }}? : Float{{ base.id }}?
      @raw.as?(Float{{ base.id }}).try &.to_f{{ base.id }}?
    end
    {% end %}

    def [](index : Int32) : Type
      case value = @raw
      when Array
        value[index]
      else
        raise "Cannot get index of type #{value.class}"
      end
    end

    def []?(index : Int32) : Type
      case value = @raw
      when Array
        value[index]?
      else
        raise "Cannot get index of type #{value.class}"
      end
    end

    def [](index : Range) : Type
      case value = @raw
      when Array
        value[index]
      else
        raise "Cannot get index of type #{value.class}"
      end
    end

    def []?(index : Range) : Type
      case value = @raw
      when Array
        value[index]?
      else
        raise "Cannot get index of type #{value.class}"
      end
    end

    def [](key : String) : Type
      case value = @raw
      when Hash
        value[index]
      else
        raise "Cannot get index of type #{value.class}"
      end
    end

    def []?(key : String) : Type
      case value = @raw
      when Hash
        value[index]
      else
        raise "Cannot get index of type #{value.class}"
      end
    end
  end
end
