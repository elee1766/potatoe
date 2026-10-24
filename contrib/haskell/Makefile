.PHONY: build potatoe deps

build: potatoe

GHC_FLAGS = ${GHCFLAGS}

potatoe: main.hs
	ghc main.hs $(GHC_FLAGS) -o potatoe

# text ships with ghc. random is the only non-boot package.
deps:
		cabal install --lib --enable-profiling --package-env . random text


clean:
	rm -rf potatoe main.hi main.o main potatoe.prof

