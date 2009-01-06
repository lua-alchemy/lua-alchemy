/* lstack.h -- Lua stack control functions
 * Author: Alexander Gladysh <agladysh@gmail.com>
 */
#ifndef LSTACK_H_
#define LSTACK_H_

/*#include <lua.h>*/
#include <lauxlib.h>

#define LCALL(L, v) int v = lua_gettop((L));
#define LCALL_ARGS(L, v, nargs) int v = lua_gettop((L)) - (nargs);

#define LTOP(L, v) (lua_gettop((L)))

#define LERROR_IMPL(L, v, msg) \
  dump_lua_stack((L), (v)); \
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
  dump_lua_stack((L), (v)); \
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

int dump_lua_stack(lua_State * L, int base);

#endif /* LSTACK_H_ */
