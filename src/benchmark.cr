require "benchmark"
require "secure_random"
require "./xxhash"

puts "Digesting blocks of 1KiB"

Benchmark.ips do |bm|
  buffer :: UInt8[1024]
  buffer.to_slice.copy_from(
    SecureRandom.random_bytes(1024).to_unsafe,
    1024
  )
  {% for bits in [32, 64] %}
    XXHash{{ bits }}.open(0) do |digester|
      bm.report("XX{{ bits }}:") do
        digester.write(buffer.to_slice)
      end

      digester.hex_digest
    end
  {% end %}
end
