.SILENT: release

hashes:
	@sha256sum potatoe
	@sha256sum quotes.txt

srcinfo:
	cd contrib/aur && makepkg --printsrcinfo > .SRCINFO
