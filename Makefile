.SILENT: release

hashes:
	@sha256sum potatoe
	@sha256sum quotes.txt

srcinfo:
	cd aur && makepkg --printsrcinfo > .SRCINFO
