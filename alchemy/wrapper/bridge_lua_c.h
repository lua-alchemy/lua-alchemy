/* bridge_lua_c.h -- Any Lua<->C bridge helper funcitons
 */
#ifndef BRIDGE_LUA_C_H_
#define BRIDGE_LUA_C_H_

#include <lua.h>

#include "lua-alchemy.h"

void fatal_error(const char * msg);

int do_pcall_with_traceback(
    lua_State * L, int narg, int nresults, BOOL is_async
  );

int panic_handler(lua_State * L);
int luaB_tostring (lua_State *L);

BOOL get_async_state(lua_State * L);

#endif /* BRIDGE_LUA_C_H_ */
