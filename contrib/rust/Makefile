.PHONY: build



build: potatoe

potatoe: target/release/potatoe
	cp target/release/potatoe potatoe

target/release/potatoe: src/main.rs
	cargo build --release
