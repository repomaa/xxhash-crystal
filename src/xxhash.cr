require "./xxhash/*"

lib LibXXHash
  enum Error
    Ok = 0
    Error
  end
end

{% for bits in [32, 64] %}
  @[Link("xxhash")]

  lib LibXXHash{{ bits }}
    fun hash = "XXH{{ bits }}"(input : Void*, size : UInt{{ bits }}, seed : UInt{{ bits }}) : Int{{ bits }}
    type State = Void*

    fun create_state = "XXH{{ bits }}_createState" : State
    fun free_state = "XXH{{ bits }}_freeState"(state : State) : LibXXHash::Error

    fun reset = "XXH{{ bits }}_reset"(state : State, seed : UInt{{ bits }}) : LibXXHash::Error
    fun update = "XXH{{ bits }}_update"(state : State, input : Void*, size : UInt{{ bits }})
    fun digest = "XXH{{ bits }}_digest"(state : State) : Int{{ bits }}
  end

  module XXHash{{ bits }}
    def digest(input, seed = 0 : Int)
      LibXXHash{{ bits }}.hash(input.to_unsafe as Void*, input.bytesize.to_u{{ bits }}, seed.to_u{{ bits }})
    end

    def hex_digest(input, seed = 0 : Int)
      digest(input, seed).to_s(16)
    end

    def open(seed = 0)
      digester = Digester.new(seed)
      begin
        yield digester
      ensure
        digester.close
      end
    end

    class Digester
      include IO

      def initialize(seed = 0 : Int)
        state = LibXXHash{{ bits }}.create_state
        unless LibXXHash{{ bits }}.reset(state, seed.to_u{{ bits }}) == LibXXHash::Error::Ok
          raise Exception.new("failed to initialize digester")
        end

        @state = state
      end

      def close
        LibXXHash{{ bits }}.free_state(@state)
      end

      def write(slice)
        LibXXHash{{ bits }}.update(@state, slice.to_unsafe as Void*, slice.size)
      end

      def read(slice)
        raise Exception.new("cannot read from digester")
      end

      def digest
        LibXXHash{{ bits }}.digest(@state)
      end

      def hex_digest
        digest.to_s(16)
      end
    end

    extend self
  end
{% end %}
