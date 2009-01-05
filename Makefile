all:
	(cd lua; make generic CFLAGS="-O2 -Wall -DLUA_USE_POSIX -DLUA_ANSI")
	(cd alchemy; make)
	(cd lua_lib; make)
	(cd test; make)
	(cd demo; make)

clean:
	rm swfbridge.log
	(cd lua;  make clean)
	rm lua/swfbridge.log
	rm lua/*achacks*
	rm -r lua/_sb_*
	rm lua/src/swfbridge.log
	rm lua/src/*achacks*
	rm -r lua/src/_sb_*
	(cd alchemy; make clean)
	(cd lua_lib; make clean)
	(cd test; make clean)
	(cd demo; make clean)
