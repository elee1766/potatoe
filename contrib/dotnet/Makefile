.PHONY: clean build


build: potatoe

potatoe: bin/release/net9.0/linux-x64/publish
	cp ./bin/release/net9.0/linux-x64/publish/potatoe .

bin/release/net9.0/linux-x64/publish: Program.cs
	dotnet publish -c release -r linux-x64


bench: clean potatoe
	hyperfine -N "./potatoe"

clean:
	rm -rf bin potatoe obj
