.PHONY: build potatoe deps

build: potatoe

GHC_FLAGS = ${GHCFLAGS}

potatoe: main.hs
	ghc main.hs $(GHC_FLAGS) -o potatoe

# not super happy with the deps here.
# random, directory is fine
# text is okay
# terminal-size and word-wrap are bad :( TODO: find an stdlib replacement for this

deps:
		cabal install --lib --enable-profiling --package-env . random directory text terminal-size word-wrap


clean:
	rm -rf potatoe main.hi main.o main potatoe.prof

