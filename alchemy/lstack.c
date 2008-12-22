/* lstack.h -- Lua stack control functions
 * Author: Alexander Gladysh <agladysh@gmail.com>
 */
#include "lstack.h"

int dump_lua_stack(lua_State * L, int base)
{
  int top = lua_gettop(L);

  if (top == 0)
  {
    lua_pushliteral(L, "-- stack is empty --");
  }
  else
  {
    int pos = 0;
    int have_tostring = 0;
    luaL_Buffer b;

    lua_getglobal(L, "tostring"); /* TODO: Reuse luaB_tostring() instead */
    have_tostring = lua_isfunction(L, -1);

    luaL_buffinit(L, &b);

    for (pos = top; pos > 0; --pos)
    {
      if (pos == base)
      {
        luaL_addstring(&b, "-- base --\n");
      }
      luaL_addstring(&b, "[");
      lua_pushinteger(L, pos);
      luaL_addvalue(&b);
      luaL_addstring(&b, "] - ");
      luaL_addstring(&b, luaL_typename(L, pos));
      luaL_addstring(&b, " - `");

      /* Call lua's tostring on value */
      if (have_tostring)
      {
        lua_pushvalue(L, top + 1);
        lua_pushvalue(L, pos);
        lua_call(L, 1, 1);
      }
      else
      {
        lua_pushvalue(L, pos);
        lua_tostring(L, -1);
      }

      luaL_addvalue(&b);
      luaL_addstring(&b, "'\n");
    }

    luaL_pushresult(&b);
    lua_remove(L, -2); /* Pop tostring() */
    if (lua_gettop(L) != top + 1)
    {
      /* Note: Can't use macros here, since macros use this function */
      return luaL_error(L, "dumpstack not balanced (1)");
    }
  }

  if (lua_gettop(L) != top + 1)
  {
    /* Note: Can't use macros here, since macros use this function */
    return luaL_error(L, "dumpstack not balanced (2)");
  }

  return 1;
}

