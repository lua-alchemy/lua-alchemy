/* lstack.h -- Lua stack control functions
 * Author: Alexander Gladysh <agladysh@gmail.com>
 */
#ifndef LSTACK_H_
#define LSTACK_H_

/* TODO: Drop that inline */
inline int Pdumpstack(lua_State * L, int base);

#define LCALL(L, v) int v = lua_gettop((L));
#define LCALL_ARGS(L, v, nargs) int v = lua_gettop((L)) - (nargs);

#define LTOP(L, v) (lua_gettop((L)))

#define LERROR_IMPL(L, v, msg) \
  Pdumpstack((L), (v)); \
  lua_pushliteral((L), __FILE__); \
  lua_pushliteral((L), "("); \
  lua_pushinteger((L), __LINE__); \
  lua_pushliteral((L), "): "); \
  lua_pushstring((L), (msg)); \
  lua_pushliteral((L), "\n"); \
  lua_concat((L), 6); \
  lua_pushvalue((L), -2); \
  lua_remove((L), -3); \
  lua_concat((L), 2);

#define LERROR(L, v, msg) \
  LERROR_IMPL((L), (v), (msg)); \
  lua_error((L));

/* WARNING: Do not store pointer in the handler! */
#define LERROR_FN(L, v, msg, fn) \
  { \
    const char * msg = NULL; \
    LERROR_IMPL((L), (v), (msg)); \
    msg = lua_tostring(L, -1); \
    lua_pop(L, 1); \
    fn(msg); \
  }

#define LCHECK_IMPL(L, v, n) \
  Pdumpstack((L), (v)); \
  lua_pushliteral((L), __FILE__); \
  lua_pushliteral((L), "("); \
  lua_pushinteger((L), __LINE__); \
  lua_pushliteral((L), "): unbalanced implementation (base at "); \
  lua_pushinteger((L), (v)); \
  lua_pushliteral((L), ", actual top at "); \
  lua_pushinteger((L), LTOP((L), (v)) - 7); \
  lua_pushliteral((L), ", expected top at "); \
  lua_pushinteger((L), (v) + (n)); \
  lua_pushliteral((L), "\n"); \
  lua_concat((L), 10); \
  lua_pushvalue((L), -2); \
  lua_remove((L), -3); \
  lua_concat((L), 2); \

#define LCHECK(L, v, n) \
  if (LTOP((L), (v)) != (v) + (n)) \
  { \
    LCHECK_IMPL((L), (v), (n)); \
    lua_error((L)); \
  }

/* WARNING: Do not store pointer in the handler! */
#define LCHECK_FN(L, v, n, fn) \
  if (LTOP((L), (v)) != (v) + (n)) \
  { \
    const char * msg = NULL; \
    LCHECK_IMPL((L), (v), (n)); \
    msg = lua_tostring(L, -1); \
    lua_pop(L, 1); \
    fn(msg); \
  }

#define LRETURN(L, v, n) LCHECK((L), (v), (n)); return (n);
#define LBASE(L, v) (v)
#define LEXTRA(L, v) (LTOP((L), (v)) - LBASE((L), (v)))
#define LABSIDX(L, v, i) ( ((i) <= 0) ? LTOP((L), (v)) + 1 + (i) : (i) )

/* TODO: Put this in the .c file, drop that inline */
inline int Pdumpstack(lua_State * L, int base)
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

#endif /* LSTACK_H_ */
