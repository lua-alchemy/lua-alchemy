.SUFFIXES: .cpp .c .o

NAME=lua-alchemy-wrapper
WRAPPER=lua_wrapper
PATH:=${ALCHEMY_HOME}/achacks:${PATH}
LUA_SRC=../lib/lua51/src
PACKAGE_WRAPPER=luaAlchemy
WRAPPER_SRC_DIR=./bin/src
GG = gluegen
INC = -I $(LUA_SRC)
CC = gcc
CCPP = g++
CFLAGS = -DTERMIOS -DL_ENDIAN -fomit-frame-pointer -O3 -Wall
LDFLAGS = -L=$(LUA_SRC) -l=lua
OBJS = bridge_as3_c.o bridge_as3_lua.o bridge_lua_c.o callbacks_as3_lua.o lstack.o as3_lua_interface.o

.cpp.o:
	$(CCPP) $(INC) $(CFLAGS) -c $<
.c.o:
	$(CC) $(INC) $(CFLAGS) -c $<

all: $(NAME).swc

glue.c : $(WRAPPER).gg
	$(GG) $(WRAPPER).gg -oas $(WRAPPER).as -cpackage cmodule.$(WRAPPER) -package $(PACKAGE_WRAPPER) -class $(WRAPPER)
	mkdir -p $(WRAPPER_SRC_DIR)/$(PACKAGE_WRAPPER)
	cp $(WRAPPER).as $(WRAPPER_SRC_DIR)/$(PACKAGE_WRAPPER)

glue.o : glue.c

$(WRAPPER).swc : glue.o $(OBJS)
	$(CC) $(INC) $(CFLAGS) -swc -o $(WRAPPER).swc glue.o $(OBJS) $(LDFLAGS)

$(NAME).swc : $(WRAPPER).swc
	compc -namespace $(PACKAGE_WRAPPER) manifest.xml -source-path $(WRAPPER_SRC_DIR) -include-namespaces $(PACKAGE_WRAPPER) -include-classes $(PACKAGE_WRAPPER).$(WRAPPER) -include-libraries $(WRAPPER).swc -target-player=10.0.0 -output='$(NAME).swc'

bridge_as3_c.o : bridge_as3_c.c bridge_as3_c.h lua-alchemy.h

bridge_as3_lua.o : bridge_as3_lua.c bridge_as3_lua.h lua-alchemy.h lstack.h bridge_as3_c.h callbacks_as3_lua.h bridge_lua_c.h

bridge_lua_c.o : bridge_lua_c.c bridge_lua_c.h lstack.h lua-alchemy.h

callbacks_as3_lua.o : callbacks_as3_lua.c callbacks_as3_lua.h lua-alchemy.h lstack.h bridge_lua_c.h bridge_as3_lua.h

lstack.o : lstack.c lstack.h

as3_lua_interface.o : as3_lua_interface.c as3_lua_interface.h lstack.h lua-alchemy.h bridge_as3_lua.h bridge_as3_c.h bridge_lua_c.h

$(WRAPPER).gg : lua-alchemy.h bridge_as3_c.h bridge_as3_lua.h bridge_lua_c.h callbacks_as3_lua.h lstack.h as3_lua_interface.h

clean:
	rm $(OBJS) glue.* $(WRAPPER).swc $(WRAPPER).as $(NAME).swc *.o
	rm swfbridge.log 
	rm *achacks*
	rm -r _sb_*
	rm -rf bin
