# TODO: Ugly copy-paste. Write a proper makefile.

all: debug release

debug:
	mxmlc -warnings -strict -optimize -debug -static-link-runtime-shared-libraries -l+=../../alchemy/lua-alchemy/build/debug/lua-alchemy.swc -o build/debug/Barebones.swf src/Barebones.as

release:
	mxmlc -warnings -strict -optimize -static-link-runtime-shared-libraries -l+=../../alchemy/lua-alchemy/build/release/lua-alchemy.swc -o build/release/Barebones.swf src/Barebones.as

clean:
	rm -r build/release/* build/debug/*
