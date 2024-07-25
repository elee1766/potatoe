.PHONY: hashes install

hashes:
	@sha256sum potatoe
	@sha256sum quotes.txt

install:
	install potatoe /usr/local/bin
	install quotes.txt /usr/lib/potatoe
