/*
** $Id: linit.c,v 1.14.1.1 2007/12/27 13:02:25 roberto Exp $
** Initialization of libraries for lua.c
** See Copyright Notice in lua.h
*/


#define linit_c
#define LUA_LIB

#include "lua.h"

#include "lualib.h"
#include "lauxlib.h"

void sztrace(char *);

static const luaL_Reg lualibs[] = {
  {"", luaopen_base},
  {LUA_LOADLIBNAME, luaopen_package},
  {LUA_TABLIBNAME, luaopen_table},
  {LUA_IOLIBNAME, luaopen_io},
  {LUA_OSLIBNAME, luaopen_os},
  {LUA_STRLIBNAME, luaopen_string},
  {LUA_MATHLIBNAME, luaopen_math},
  {LUA_DBLIBNAME, luaopen_debug},
  {NULL, NULL}
};


LUALIB_API void luaL_openlibs (lua_State *L) {
  sztrace("0051 -- luaL_openlibs BEGIN 1");
  const luaL_Reg *lib = lualibs;
  char buf[4096];
  sztrace("0052");
  for (; lib->func; lib++) {
    sztrace("0053");
    sprintf(
        buf,
        "0053.1 name %s L %p lib %p func %p",
        lib->name, L, lib, lib->func
      );
    sztrace(buf);
    sztrace("0054");
    lua_pushcfunction(L, lib->func);
    sztrace("0055");
    lua_pushstring(L, lib->name);
    sztrace("0056");
    lua_call(L, 1, 0);
    sztrace("0058");
  }
  sztrace("0059 -- luaL_openlibs BEGIN");
}

