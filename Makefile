.SILENT: release

pkgver=0.0.1

release:
	curl -sL "https://raw.githubusercontent.com/elee1766/potatoe/v${pkgver}/potatoe" | sha256sum
	curl -sL "https://raw.githubusercontent.com/elee1766/potatoe/v${pkgver}/quotes.txt" | sha256sum

