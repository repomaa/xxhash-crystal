require "benchmark"
require "secure_random"
require "./xxhash"

abstract struct Number
  def humanize
    units = %w[B KiB MiB GiB]

    value = self
    unit = units.shift

    while value >= 1024
      value /= 1024
      unit = units.shift
    end

    "#{value}#{unit}"
  end
end

struct Int32
  def kib
    1024_u64 * self
  end

  def mib
    1024.kib * self
  end

  def gib
    1024.mib * self
  end
end

BLOCK_SIZE = 4096

data_size = (ENV["DATA_SIZE_GIB"]?.try(&.to_i) || 4).gib
puts "Hashing #{data_size.humanize} of (semi)random data"

Benchmark.bm do |bm|
  data = IO::Memory.new(2.mib).tap do |io|
    (2.mib / BLOCK_SIZE).times do
      io.write(SecureRandom.random_bytes(BLOCK_SIZE))
    end
  end

  {% for bits in [32, 64] %}
    bm.report("XXHash{{bits}}") do
      XXHash{{ bits }}.open(0) do |digester|
        (data_size / 2.mib).times do
          data.rewind
          IO.copy(data, digester)
        end

        digester.hex_digest
      end
    end
  {% end %}
end
