all: bench

bench: dist/benchmark
	dist/benchmark

dist/benchmark:
	crystal build -o dist/benchmark --release src/benchmark.cr

.PHONY: all
