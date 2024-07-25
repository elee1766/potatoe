.PHONY: hashes install

hashes:
	@sha256sum potatoe
	@sha256sum quotes.txt

install:
	install -D -t /usr/local/bin/ potatoe
	install -D -t /usr/lib/potatoe/ quotes.txt
