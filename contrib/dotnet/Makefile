.PHONY: clean build


build: potatoe

potatoe: bin/release/net10.0/linux-x64/publish
	cp ./bin/release/net10.0/linux-x64/publish/potatoe .

bin/release/net10.0/linux-x64/publish: Program.cs
	dotnet publish -c release -r linux-x64

clean:
	rm -rf bin potatoe obj

bench: clean potatoe
	hyperfine -N "./potatoe"

