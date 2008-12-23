/*as3_lua_interface.h -- AS3 Interface exported to lua
 */
#ifndef AS3_LUA_INTERFACE_H_
#define AS3_LUA_INTERFACE_H_

#include <lua.h>

void register_as3_lua_interface(lua_State * L);

int as3_yield(lua_State * L);
int as3_yield(lua_State * L);
int as3_stage(lua_State * L);
int as3_class(lua_State * L);
int as3_new(lua_State * L);
int as3_release(lua_State * L);
int as3_tolua(lua_State * L);
int as3_get(lua_State * L);
int as3_set(lua_State * L);
int as3_assign(lua_State * L);
int as3_call(lua_State * L);
int as3_type(lua_State * L);
int as3_namespacecall(lua_State * L);
int as3_trace(lua_State * L);

#endif /* AS3_LUA_INTERFACE_H_ */
