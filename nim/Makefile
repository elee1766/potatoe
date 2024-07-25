.PHONY: clean


potatoe: potatoe.nim
	nim c -d:release \
	  --opt:speed \
		--passL:"-flto" \
		--passC:"-O3 -flto -m64" \
		--mm:arc \
		potatoe.nim

bench: clean potatoe
	hyperfine -N "./potatoe"

clean:
	rm -rf potatoe
