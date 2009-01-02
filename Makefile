all:
	(cd lua; make generic CFLAGS="-O2 -Wall -DLUA_USE_POSIX -DLUA_ANSI")
	(cd alchemy; make)
	(cd test/FluintLuaTests; ant)
	(cd demo/LuaAlchemyDemo; ant)
	(cd demo/MiniDemo; ant)

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
	(cd test/FluintLuaTests; ant clear)
	(cd demo/LuaAlchemyDemo; ant clear)
	(cd demo/MiniDemo; ant clear)
