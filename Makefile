all:
	(cd alchemy; make)
	(cd test; make)
	(cd demo; make)

clean:
	rm swfbridge.log
	(cd alchemy; make clean)
	(cd test; make clean)
	(cd demo; make clean)
