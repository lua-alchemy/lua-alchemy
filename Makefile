all:
	(cd alchemy; make)
	(cd lua_lib; make)
	(cd test; make)
	(cd demo; make)

clean:
	rm swfbridge.log
	(cd alchemy; make clean)
	(cd lua_lib; make clean)
	(cd test; make clean)
	(cd demo; make clean)
