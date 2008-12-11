.SUFFIXES: .cpp .c .o

NAME=lua_wrapper
PATH:=${ALCHEMY_HOME}/achacks:${PATH}
LUA_SRC=../lua/src
PACKAGE_NAME=luaAlchemy
WRAPPER_AS_DIR=./bin/src/${PACKAGE_NAME}
WRAPPER_SWC_DIR=./bin/swc
GG = gluegen
INC = -I $(LUA_SRC)
CC = gcc
CCPP = g++
CFLAGS = -DTERMIOS -DL_ENDIAN -fomit-frame-pointer -O3 -Wall
LDFLAGS = -L=$(LUA_SRC) -l=lua
OBJS =

.cpp.o:
	$(CCPP) $(INC) $(CFLAGS) -c $<
.c.o:
	$(CC) $(INC) $(CFLAGS) -c $<

all: $(NAME)

glue.c : $(NAME).gg
	$(GG) $(NAME).gg -oas $(NAME).as -cpackage cmodule.$(NAME) -package $(PACKAGE_NAME) -class $(NAME)
	mkdir -p $(WRAPPER_AS_DIR)
	cp $(NAME).as $(WRAPPER_AS_DIR)

glue.o : glue.c

$(NAME) : glue.o $(OBJS)
	$(CC) $(INC) $(CFLAGS) -swc -o $(NAME).swc glue.o $(OBJS) $(LDFLAGS)
	mkdir -p $(WRAPPER_SWC_DIR)
	cp $(NAME).swc $(WRAPPER_SWC_DIR)

clean:
	rm $(OBJS) glue.* $(NAME).swc 
	rm swfbridge.log 
	rm *achacks*
	rm -r _sb_*
	rm $(WRAPPER_AS_DIR)/$(NAME).as
	rm $(WRAPPER_SWC_DIR)/$(NAME).swc
