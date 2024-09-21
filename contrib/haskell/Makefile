.PHONY: build potatoe deps

build: potatoe

potatoe: main.hs
	ghc main.hs -O2 -funfolding-use-threshold=16 -optc-O3 -o potatoe

# not super happy with the deps here.
# random, directory is fine
# text is okay
# terminal-size is bad :( TODO: find an stdlib replacement for this

deps:
		cabal install --lib --package-env . random directory text terminal-size word-wrap


clean:
	rm -rf potatoe main.hi main.o main

