# xxhash-crystal

These are the crystal bindings for [xxHash](https://github.com/Cyan4973/xxHash)
- An extremely fast non-cryptographic hash algorithm

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  xxhash:
    github: jreinert/xxhash-crystal
```

## Usage

This library provides bindings for both the 64 and 32 bit version of xxHash
They are accessed through the modules `XXHash32` and `XXHash64` respectively.

You should use the one that matches your cpu architecture.

```crystal
require "xxhash"

# Pass a nn-bit seed
seed = (Random::Secure.random_bytes(8).to_unsafe.as(UInt64*)).value
puts XXHash64.hex_digest("foobar", seed)

# Or use 0 by default
puts XXHash64.hex_digest("foobar")

# Stream data
XXHash64.open(seed) do |digester|
  IO.copy(some_io, digester)
  puts digester.hex_digest
end
```

## Benchmarks

Run with `make bench`. Set the `DATA_SIZE_GIB` environment variable to alter
used data size.

```
Hashing 16GiB of (semi)random data
               user     system      total        real
XXHash32   4.250000   0.000000   4.250000 (  4.247582)
XXHash64   2.410000   0.000000   2.410000 (  2.413591)
```

## Contributing

1. Fork it ( https://github.com/jreinert/xxhash/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [jreinert](https://github.com/jreinert) Joakim Reinert - creator, maintainer
