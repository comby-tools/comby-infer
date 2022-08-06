all:
	@dune build --profile dev

dev:
	@dune build --watch --profile dev

release:
	@dune build --profile release

clean:
	@dune clean

test:
	@dune runtest

promote:
	@dune promote

run:
	@dune exec ./server.exe

format:
	@dune build @fmt --auto-promote

.PHONY: all dev clean test promote run format
