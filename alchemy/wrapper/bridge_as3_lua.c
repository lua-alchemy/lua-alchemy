/* bridge_as3_lua.h -- Any Lua<->C bridge helper funcitons
 */
#include "bridge_as3_lua.h"

#include "lstack.h"
#include "bridge_as3_c.h"
#include "callbacks_as3_lua.h"
#include "bridge_lua_c.h"

int push_as3_array_to_lua_stack(lua_State * L, AS3_Val array)
{
  LCALL(L, stack);

  int len = 0;
  int i = 0;
  AS3_Val cur;

  if (!AS3_InstanceOf(array, Array_class))
  {
    LRETURN(L, stack, 0);
  }

  len = AS3_IntValue(AS3_GetS(array, "length"));
  for (i = 0; i < len; i++)
  {
    cur = AS3_Get(array, AS3_Int(i));
    push_as3_lua_userdata(L, cur);
    AS3_Release(cur);
  }

  LRETURN(L, stack, len);
}

/*
* Take the foreign userdata at given Lua stack index
* and convert it into an ActionScriptValue.
* TODO: Wrap it into a black-box value.
*/
AS3_Val as3_value_from_foreign_userdata(lua_State * L, int index)
{
  return AS3_String("userdata");
}

/*
* Take the Lua stack item at index i and convert it into an
* ActionScript value.
*/
AS3_Val get_as3_value_from_lua_stack_type(lua_State * L, int i, int type)
{
  /* WARNING: Panic alert! Use L*_FN checkers here! */

  LCALL(L, stack);

  AS3_Val value;
  switch (type)
  {
    case LUA_TSTRING:  /* strings */
      {
        size_t length = 0;
        const char * str = lua_tolstring(L, i, &length);
        if (str == NULL)  /* NOTE: This is unreachable. Assert instead */
        {
          length = 6;
          str = "(null)";
        }
        /* NOTE: Alchemy .5a truncates embedded zeroes in string regardless to the passed length */
        value = AS3_StringN(str, length);
      }
      break;

    case LUA_TBOOLEAN:  /* booleans */
      value = lua_toboolean(L, i) ? AS3_True() : AS3_False();
      break;

    case LUA_TNUMBER:  /* numbers */
      value = AS3_Number(lua_tonumber(L, i));
      break;

    case LUA_TNONE: /* fall through */
    case LUA_TNIL:  /* nil */
      value = AS3_Null();
      break;

    case LUA_TUSERDATA:  /* userdata */
      {
        void * userdata = lua_touserdata(L, i);
        lua_getfield(L, LUA_REGISTRYINDEX, AS3LUA_METATABLE);
        if (userdata == NULL || !lua_getmetatable(L, i))
        {
          lua_pop(L, 1); /* Pop AS3LUA_METATABLE */
          value = as3_value_from_foreign_userdata(L, i);
        }
        else if (!lua_rawequal(L, -2, -1))
        {
          lua_pop(L, 2); /* Pop AS3LUA_METATABLE and userdata metatable */
          value = as3_value_from_foreign_userdata(L, i);
        }
        else
        {
          lua_pop(L, 2); /* Pop AS3LUA_METATABLE and userdata metatable */
          AS3LuaUserData * userdata = (AS3LuaUserData *)lua_touserdata(L, i);
          value = userdata->value;
        }
      }
      break;

    case LUA_TFUNCTION: /* function */
      value = setup_callback(L, i);
      break;

    case LUA_TLIGHTUSERDATA: /* TODO: blackbox this type */
    case LUA_TTABLE: /* TODO: deal with this type */
    case LUA_TTHREAD: /* TODO: blackbox this type */
      value = AS3_String(lua_typename(L, type));
      break;

    default:  /* unreachable */
      fatal_error("unknown Lua type");
      break;
  }

#ifdef DO_SPAM
  SPAM(("get_as3_value_from_lua_stack(): end"));
  AS3_Trace(AS3_Call(getQualifiedClassName_method, NULL, AS3_Array("AS3ValType", value)));
#endif /* DO_SPAM */

  LCHECK_FN(L, stack, 0, fatal_error);

  return value;
}

AS3_Val get_as3_value_from_lua_stack(lua_State * L, int i)
{
  return get_as3_value_from_lua_stack_type(L, i, lua_type(L, i));
}

/*
* Create an ActionScript value from the lua stack starting
* at index start and ending at index end.  If collapse_array == 1,
* an empty return will be transformed into AS3_Undefined() and a
* return of length 1 will just return the specific value.
* Otherwise an array is returned.
*/
AS3_Val create_as3_value_from_lua_stack(
    lua_State * L,
    int start,
    int end,
    BOOL collapse_array
  )
{
  /* WARNING: Panic alert! Use L*_FN checkers here! */

  LCALL(L, stack);
  AS3_Val ret;
  AS3_Val value;

  SPAM(("create_as3_value_from_lua_stack(): begin"));

  if (collapse_array == TRUE && start > end)
  {
    ret = AS3_Null();
  }
  else if (collapse_array == TRUE && start == end)
  {
    ret = get_as3_value_from_lua_stack(L, start);
  }
  else
  {
    int i;

    ret = AS3_Array("");
    for (i = start; i <= end; ++i)
    {
      AS3_Val as3Value;

      /*SPAM(("create_as3_value_from_lua_stack() + 1 begin"));*/
      value = get_as3_value_from_lua_stack(L, i);
      as3Value = AS3_Array("AS3ValType", value);
      AS3_CallS("push", ret, as3Value);
      AS3_Release(as3Value);
      /*SPAM(("create_as3_value_from_lua_stack() + 1 end"));*/
    }
  }

#ifdef DO_SPAM
  SPAM(("create_as3_value_from_lua_stack(): end"));
  AS3_Trace(AS3_Call(getQualifiedClassName_method, NULL, AS3_Array("AS3ValType", ret)));
#endif /* DO_SPAM */

  LCHECK_FN(L, stack, 0, fatal_error);

  return ret;
}

/*
* Take the given ActionScript value and push it onto the
* stack with the correct metatable.
*/
int push_as3_lua_userdata(lua_State * L, AS3_Val val)
{
  LCALL(L, stack);

  AS3LuaUserData * userdata = NULL;

  AS3_Acquire(val);

  userdata = (AS3LuaUserData *)lua_newuserdata(L, sizeof(AS3LuaUserData));
  userdata->value = val;

  luaL_getmetatable(L, AS3LUA_METATABLE);
  lua_setmetatable(L, -2);

  LRETURN(L, stack, 1);
}

/*
* Given an ActionScript object, push it onto the Lua stack as a Lua native
* type if a primitive class (String, Number, Boolean, int, null).
* If object is not convertible to native Lua value, do not push anything (and return 0).
*/
int push_as3_to_lua_stack_if_convertible(lua_State * L, AS3_Val val)
{
  LCALL(L, stack);

#ifdef DO_SPAM
  SPAM(("push_as3_to_lua_stack_if_convertible(): begin: value, type"));
  AS3_Trace(val);
  AS3_Trace(AS3_Call(getQualifiedClassName_method, NULL, AS3_Array("AS3ValType", val)));
#endif /* DO_SPAM */

  if (AS3_InstanceOf(val, Number_class))
  {
    lua_pushnumber(L, AS3_NumberValue(val));
  }
  else if (AS3_InstanceOf(val, int_class))
  {
    lua_pushinteger(L, AS3_IntValue(val));
  }
  else if (AS3_InstanceOf(val, String_class))
  {
    /* TODO: Release?! */
    size_t length = 0;
    AS3_Malloced_Str str = get_string_bytes(val, &length);

    lua_pushlstring(L, str, length);

    free(str);
  }
  else if (AS3_InstanceOf(val, Boolean_class))
  {
    lua_pushboolean(L, AS3_IntValue(val));
  }
  else if (val == AS3_Undefined())
  {
    lua_pushnil(L);
  }
  else if (is_null(val))
  {
    lua_pushnil(L);
  }
  else
  {
    SPAM(("push_as3_to_lua_stack_if_convertible(): not convertible"));
    LRETURN(L, stack, 0);
  }

  SPAM(("push_as3_to_lua_stack_if_convertible(): end"));

  LRETURN(L, stack, 1);
}

/*
* Given an ActionScript object, push it onto the Lua stack as a Lua native
* type if a primitive class (String, Number, Boolean, int, null)
* or push as userdata
*/
int push_as3_to_lua_stack(lua_State * L, AS3_Val val)
{
  LCALL(L, stack);

  if (push_as3_to_lua_stack_if_convertible(L, val) == 0)
  {
    SPAM(("push_as3_to_lua_stack(): defaulting to userdata"));
    push_as3_lua_userdata(L, val);
  }

  LRETURN(L, stack, 1);
}


