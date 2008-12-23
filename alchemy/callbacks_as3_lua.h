/* callbacks_as3_lua.h -- Handle creation and management of Lua function callbacks returned on stack
 */
#ifndef CALLBACKS_AS3_LUA_H_
#define CALLBACKS_AS3_LUA_H_

#include <AS3.h>
#include <lua.h>

void initialize_callbacks(lua_State * L);
AS3_Val setup_callback(lua_State * L, int index);

#endif /* CALLBACKS_AS3_LUA_H_ */
