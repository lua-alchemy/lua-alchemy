all:
	(cd lua;  make generic)
	(cd alchemy; make)

clean:
	(cd lua;  make clean)
	rm lua/swfbridge.log 
	rm lua/*achacks*
	rm -r lua/_sb_*
	(cd alchemy; make clean)
