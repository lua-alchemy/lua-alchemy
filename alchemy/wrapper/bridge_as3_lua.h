/* bridge_as3_lua.h -- Any Lua<->C bridge helper funcitons
 */
#ifndef BRIDGE_AS3_LUA_H_
#define BRIDGE_AS3_LUA_H_

#include <AS3.h>
#include <lua.h>

#include "lua-alchemy.h"

typedef struct AS3LuaUserData
{
  AS3_Val value;
} AS3LuaUserData;

AS3_Val create_as3_value_from_lua_stack(
    lua_State * L,
    int start,
    int end,
    BOOL collapse_array
  );
int push_as3_lua_userdata(lua_State * L, AS3_Val val);

int push_as3_to_lua_stack(lua_State * L, AS3_Val val);
int push_as3_to_lua_stack_if_convertible(lua_State * L, AS3_Val val);

int push_as3_array_to_lua_stack(lua_State * L, AS3_Val array);

AS3_Val as3_value_from_foreign_userdata(lua_State * L, int index);
AS3_Val get_as3_value_from_lua_stack_type(lua_State * L, int i, int type);
AS3_Val get_as3_value_from_lua_stack(lua_State * L, int i);

#endif /* BRIDGE_AS3_LUA_H_ */
