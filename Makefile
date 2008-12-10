all:
	(cd lua;  make generic)
	(cd alchemy; make)
	(cd test/FluintLuaTests; ant)

clean:
	(cd lua;  make clean)
	rm lua/swfbridge.log 
	rm lua/*achacks*
	rm -r lua/_sb_*
	(cd alchemy; make clean)
	(cd test/FluintLuaTests; ant clear)
