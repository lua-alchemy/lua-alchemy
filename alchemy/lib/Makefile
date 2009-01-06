all:
	(cd lua51; make generic CFLAGS="-O2 -Wall -DLUA_USE_POSIX -DLUA_ANSI")

clean:
	(cd lua51;  make clean)
	rm lua/swfbridge.log
	rm lua/*achacks*
	rm -r lua/_sb_*
	rm lua/src/swfbridge.log
	rm lua/src/*achacks*
	rm -r lua/src/_sb_*
