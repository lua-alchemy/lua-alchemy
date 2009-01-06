/*as3_lua_interface.h -- AS3 Interface exported to lua
 */
#ifndef AS3_LUA_INTERFACE_H_
#define AS3_LUA_INTERFACE_H_

#include <lua.h>

void register_as3_lua_interface(lua_State * L);

int as3_trace(lua_State * L); /* Exposed to be able to do debug dumps */

#endif /* AS3_LUA_INTERFACE_H_ */
