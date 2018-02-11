require "./xxhash/*"

lib LibXXHash
  enum Error
    Ok    = 0
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
    def digest(input, seed : Int = 0)
      LibXXHash{{ bits }}.hash(input.to_unsafe.as(Void*), input.bytesize.to_u{{ bits }}, seed.to_u{{ bits }})
    end

    def hex_digest(input, seed : Int = 0)
      hash = digest(input, seed)
      hash_to_hex(hash)
    end

    def open(seed = 0)
      digester = Digester.new(seed)
      begin
        yield digester
      ensure
        digester.close
      end
    end

    def hash_to_hex(hash)
      bytes = (pointerof(hash).as(UInt8[{{ bits / 8 }}]*)).value
      bytes.reverse!
      bytes.map { |byte| "%02x" % byte }.join
    end

    class Digester < IO
      @state : LibXXHash{{ bits }}::State

      def initialize(@seed : Int = 0)
        @state = create_state(@seed)
      end

      def finalize
        close unless @closed
      end

      def close
        LibXXHash{{ bits }}.free_state(@state)
        @closed = true
      end

      def write(slice)
        LibXXHash{{ bits }}.update(@state, slice.to_unsafe.as(Void*), slice.size)
      end

      def read(slice)
        raise Exception.new("cannot read from digester")
      end

      def rewind
        close
        @state = create_state(@seed)
      end

      def digest
        LibXXHash{{ bits }}.digest(@state)
      end

      def hex_digest
        XXHash{{ bits }}.hash_to_hex(digest)
      end

      private def create_state(seed)
        state = LibXXHash{{ bits }}.create_state
        unless LibXXHash{{ bits }}.reset(state, seed.to_u{{ bits }}) == LibXXHash::Error::Ok
          raise Exception.new("failed to initialize digester")
        end

        @closed = false
        state
      end
    end

    extend self
  end
{% end %}
