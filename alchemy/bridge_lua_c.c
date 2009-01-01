/* bridge_lua_c.h -- Any Lua<->C bridge helper funcitons
 */
#include "bridge_lua_c.h"

#include <stdlib.h>

#include <lauxlib.h>
#include <lualib.h>

#include "lua-alchemy.h"
#include "lstack.h"

/* TODO: Use some better Alchemy API */
void fatal_error(const char * msg)
{
  sztrace("Lua Alchemy fatal error");
  sztrace((char *)msg);
  exit(-1);
}

/* Two arguments version to avoid string concatenation */
void fatal_error2(const char * msg1, const char * msg2)
{
  sztrace("Lua Alchemy fatal error");
  sztrace((char *)msg1);
  sztrace((char *)msg2);
  exit(-1);
}

int panic_handler(lua_State * L)
{
  const char * pStr = lua_tostring(L, -1);
  if (pStr != NULL)
  {
    /*
      NOTE: Not doing pop, since we would exit program anyway,
            and Lua interpreter 'L' is in 'undefined state'.
      lua_pop(L, 1);
    */

    fatal_error2("Lua panicked:", (char *)pStr);
  }

  fatal_error("Lua panicked, failed to get error message.");

  return 1; /* Unreachable */
}

/*
 * BEGIN COPY-PASTE FROM Lua 5.1.4 ldblib.c
 */

static lua_State *getthread (lua_State * L, int *arg) {
  if (lua_isthread(L, 1)) {
    *arg = 1;
    return lua_tothread(L, 1);
  }
  else {
    *arg = 0;
    return L;
  }
}

#define LEVELS1 12  /* size of the first part of the stack */
#define LEVELS2 10  /* size of the second part of the stack */

static int db_errorfb (lua_State * L) {
  int level;
  int firstpart = 1;  /* still before eventual `...' */
  int arg;
  lua_State * L1 = getthread(L, &arg);
  lua_Debug ar;
  if (lua_isnumber(L, arg+2)) {
    level = (int)lua_tointeger(L, arg+2);
    lua_pop(L, 1);
  }
  else
    level = (L == L1) ? 1 : 0;  /* level 0 may be this own function */
  if (lua_gettop(L) == arg)
    lua_pushliteral(L, "");
  else if (!lua_isstring(L, arg+1)) return 1;  /* message is not a string */
  else lua_pushliteral(L, "\n");
  lua_pushliteral(L, "stack traceback:");
  while (lua_getstack(L1, level++, &ar)) {
    if (level > LEVELS1 && firstpart) {
      /* no more than `LEVELS2' more levels? */
      if (!lua_getstack(L1, level+LEVELS2, &ar))
        level--;  /* keep going */
      else {
        lua_pushliteral(L, "\n\t...");  /* too many levels */
        while (lua_getstack(L1, level+LEVELS2, &ar))  /* find last levels */
          level++;
      }
      firstpart = 0;
      continue;
    }
    lua_pushliteral(L, "\n\t");
    lua_getinfo(L1, "Snl", &ar);
    lua_pushfstring(L, "%s:", ar.short_src);
    if (ar.currentline > 0)
      lua_pushfstring(L, "%d:", ar.currentline);
    if (*ar.namewhat != '\0')  /* is there a name? */
        lua_pushfstring(L, " in function " LUA_QS, ar.name);
    else {
      if (*ar.what == 'm')  /* main? */
        lua_pushfstring(L, " in main chunk");
      else if (*ar.what == 'C' || *ar.what == 't')
        lua_pushliteral(L, " ?");  /* C function or tail call */
      else
        lua_pushfstring(L, " in function <%s:%d>",
                           ar.short_src, ar.linedefined);
    }
    lua_concat(L, lua_gettop(L) - arg);
  }
  lua_concat(L, lua_gettop(L) - arg);
  return 1;
}

/*
 * END COPY-PASTE FROM Lua 5.1.4 ldblib.c
 */

#undef LEVELS1
#undef LEVELS2

/*
 * BEGIN COPY-PASTE FROM Lua 5.1.4 lbaselib.c
 */

int luaB_tostring (lua_State *L) {
  luaL_checkany(L, 1);
  if (luaL_callmeta(L, 1, "__tostring"))  /* is there a metafield? */
    return 1;  /* use its value */
  switch (lua_type(L, 1)) {
    case LUA_TNUMBER:
      lua_pushstring(L, lua_tostring(L, 1));
      break;
    case LUA_TSTRING:
      lua_pushvalue(L, 1);
      break;
    case LUA_TBOOLEAN:
      lua_pushstring(L, (lua_toboolean(L, 1) ? "true" : "false"));
      break;
    case LUA_TNIL:
      lua_pushliteral(L, "nil");
      break;
    default:
      lua_pushfstring(L, "%s: %p", luaL_typename(L, 1), lua_topointer(L, 1));
      break;
  }
  return 1;
}

/*
 * END COPY-PASTE FROM Lua 5.1.4 lbaselib.c
 */

int do_pcall_with_traceback(lua_State * L, int narg, int nresults)
{
  /* WARNING: Panic alert! Use L*_FN checkers here! */

  SPAM(("do_pcall_with_traceback(): begin"));

  LCALL_ARGS(L, stack, 1 + narg); /* The function itself with arguments */
  int status = 0;

  lua_pushcfunction(L, db_errorfb);  /* push traceback function */
  lua_insert(L, LBASE(L, stack));  /* put it under chunk and args */

  LCHECK_FN(L, stack, 1 + narg + 1, fatal_error);

  SPAM(("do_pcall_with_traceback(): before call"));

  status = lua_pcall(L, narg, nresults, LBASE(L, stack));

  lua_remove(L, LBASE(L, stack));  /* remove traceback function */

  if (status != 0)
  {
    SPAM(("do_pcall_with_traceback(): after call ERROR"));

    /* force a complete garbage collection in case of errors */
    lua_gc(L, LUA_GCCOLLECT, 0);

    LCHECK_FN(L, stack, 1, fatal_error);
  }
  else
  {
    SPAM(("do_pcall_with_traceback(): after call OK"));

    if (nresults != LUA_MULTRET)
    {
      LCHECK_FN(L, stack, nresults, fatal_error);
    }
  }

  SPAM(("do_pcall_with_traceback(): end"));

  return status;
}

