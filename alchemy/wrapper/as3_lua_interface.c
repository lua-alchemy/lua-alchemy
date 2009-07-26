/* as3_lua_interface.c -- AS3 Interface exported to lua
 */

#include "as3_lua_interface.h"

#include "lua-alchemy.h"
#include "lstack.h"
#include "bridge_as3_lua.h"
#include "bridge_as3_c.h"
#include "bridge_lua_c.h"

#define check_as3userdata(L, index) \
  (AS3LuaUserData *)luaL_checkudata(L, index, AS3LUA_METATABLE)

/*
* Release control to Flash and return to this point on the next timer tick
* Lua example: as3.flyield()
*/
static int as3_flyield(lua_State * L)
{
  LCALL(L, stack);

  flyield();

  LRETURN(L, stack, 0);
}

/*
* Return the Flash stage
* Lua example: as3.stage()
*/
static int as3_stage(lua_State * L)
{
  LCALL(L, stack);

  /* TODO: This is currently void, call setSprite() before init() to fix */
  push_as3_lua_userdata(L, AS3_Stage());

  LRETURN(L, stack, 1);
}

/*
* Return the requested class in package::ClassName form.
* Can be used to call static class functions
* Lua example: v = as3.newclass("flash.utils.ByteArray")
*/
static int as3_newclass(lua_State * L)
{
  LCALL(L, stack);

  const char * classname = NULL;
  AS3_Val as_class;

  classname = lua_tostring(L, 1);
  luaL_argcheck(L, classname != NULL, 1, LUA_QL("package::ClassName") " expected");

  as_class = get_class(classname);
  if (as_class == NULL)
  {
    return luaL_error(L, "newclass: invalid package::ClassName: " LUA_QL("%s"), classname);
  }

  push_as3_lua_userdata(L, as_class);

  AS3_Release(as_class);

  LRETURN(L, stack, 1);
}

/*
* Return the requested class in package::ClassName form.
* Can be used to call static class functions
* Lua example: v = as3.newclass2("flash.utils", "ByteArray")
* Namespace may be empty (pass nil, false or empty string)
* NOTE: This function is intentionally not documented.
*/
static int as3_newclass2(lua_State * L)
{
  LCALL(L, stack);

  const char * namespacename = NULL;
  const char * classname = NULL;
  AS3_Val as_class;

  if (lua_toboolean(L, 1))
  {
    namespacename = luaL_checkstring(L, 1);
    if (namespacename[0] == '\0')
    {
      namespacename = NULL;
    }
  }
  classname = luaL_checkstring(L, 2);

  as_class = get_class2(namespacename, classname);
  if (as_class == NULL)
  {
    return luaL_error(
        L,
        "newclass2: invalid package::ClassName: " LUA_QL("%s::%s"),
        namespacename,
        classname
      );
  }

  push_as3_lua_userdata(L, as_class);

  AS3_Release(as_class);

  LRETURN(L, stack, 1);
}

/*
* Create a new instance of the given class in package::ClassName form.
* Lua example: v = as3.new("flash.utils.ByteArray")
*/
static int as3_new(lua_State * L)
{
  LCALL(L, stack);

  const char * classname = NULL;
  AS3_Val as_class;
  AS3_Val params;
  AS3_Val as_object;

  classname = lua_tostring(L, 1);
  luaL_argcheck(L, classname != NULL, 1, LUA_QL("package::ClassName") " expected");

  as_class = get_class(classname);
  if (as_class == NULL)
  {
    return luaL_error(
        L,
        "invalid package::ClassName: " LUA_QL("%s"),
        classname
      );
  }

  params = create_as3_value_from_lua_stack(L, 2, LTOP(L, stack), FALSE);

  as_object = AS3_New(as_class, params);
  if (as_object == NULL)
  {
    AS3_Release(as_class);
    AS3_Release(params);
    return luaL_error(
        L,
        "failed to create object of type: " LUA_QL("%s"),
        classname
      );
  }

  push_as3_lua_userdata(L, as_object);

  /* AS3_Release(as_object); // TODO: ?!?!?! push_as3_lua_userdata does not do AS3_Acquire! */
  AS3_Release(params);
  AS3_Release(as_class); /* TODO might want to store classes in a table to save loading again */

  LRETURN(L, stack, 1);
}

/*
* Create a new instance of the given class in package::ClassName form.
* Lua example: v = as3.new2("flash.utils", "ByteArray")
* Namespace may be empty (pass nil, false or empty string)
* NOTE: This function is intentionally not documented.
*/
static int as3_new2(lua_State * L)
{
  LCALL(L, stack);

  const char * namespacename = NULL;
  const char * classname = NULL;
  AS3_Val as_class;
  AS3_Val params;
  AS3_Val as_object;

  if (lua_toboolean(L, 1))
  {
    namespacename = luaL_checkstring(L, 1);
    if (namespacename[0] == '\0')
    {
      namespacename = NULL;
    }
  }
  classname = luaL_checkstring(L, 2);

  as_class = get_class2(namespacename, classname);
  if (as_class == NULL)
  {
    return luaL_error(
        L,
        "invalid package::ClassName: " LUA_QL("%s::%s"),
        namespacename,
        classname
      );
  }

  params = create_as3_value_from_lua_stack(L, 3, LTOP(L, stack), FALSE);

  as_object = AS3_New(as_class, params);
  if (as_object == NULL)
  {
    AS3_Release(as_class);
    AS3_Release(params);
    return luaL_error(
        L,
        "failed to create object of type: " LUA_QL("%s::%s"),
        namespacename,
        classname
      );
  }

  push_as3_lua_userdata(L, as_object);

  /* AS3_Release(as_object); // TODO: ?!?!?! push_as3_lua_userdata does not do AS3_Acquire! */
  AS3_Release(params);
  AS3_Release(as_class); /* TODO might want to store classes in a table to save loading again */

  LRETURN(L, stack, 1);
}

/*
* Release the given ActionScript object so Flash will do garbage collection.
* Lua example: as3.release(v)
*/
static int as3_release(lua_State * L)
{
  SPAM(("as3_release() : begin"));

  LCALL(L, stack);

  AS3LuaUserData * userdata = check_as3userdata(L, 1);

  if (userdata->value != AS3_Undefined())
  {
    AS3_Release(userdata->value);
    userdata->value = AS3_Undefined();
  }

  SPAM(("as3_release() : end"));

  LRETURN(L, stack, 0);
}

/*
* Convert ActionScript to a Lua type if possible (see push_as3_to_lua_stack).
* Supports multiple arguments.
* If conversion is not possible, this will return the original AS object.
* If argument is a Lua value, it is returned intact.</p>
* Lua example: as3.tolua(v)
*/
static int as3_tolua(lua_State * L)
{
  LCALL(L, stack);

  int i = 1;

  lua_getfield(L, LUA_REGISTRYINDEX, AS3LUA_METATABLE);

  for (i = 1; i <= LBASE(L, stack); ++i)
  {
    void * userdata = lua_touserdata(L, i);
    if (userdata == NULL || !lua_getmetatable(L, i))
    {
      lua_pushvalue(L, i);
    }
    else if (!lua_rawequal(L, LBASE(L, stack) + 1, -1))
    {
      lua_pop(L, 1); /* Pop userdata metatable */
      lua_pushvalue(L, i);
    }
    else
    {
      AS3LuaUserData * as3_userdata = (AS3LuaUserData *)userdata;

      lua_pop(L, 1); /* Pop userdata metatable */
      if (push_as3_to_lua_stack_if_convertible(L, as3_userdata->value) == 0)
      {
        /* AS3 value is not convertible to native Lua. Reuse userdata. */
        lua_pushvalue(L, i);
      }
    }
  }

  lua_remove(L, LBASE(L, stack) + 1); /* Remove AS3LUA_METATABLE */

  LRETURN(L, stack, LBASE(L, stack));
}

/*
* Return the requested property of a given ActionScript object.  The value
* is always returned as an AS3 type
* Lua example: as3.get(v, "text")
*/
static int as3_get(lua_State * L)
{
  LCALL(L, stack);

  AS3LuaUserData * userdata = NULL;
  const char * property = NULL;
  AS3_Val val;

  userdata = check_as3userdata(L, 1);

  property = lua_tostring(L, 2);
  luaL_argcheck(L, property != NULL, 2, "'property' expected");

  val = AS3_GetS(userdata->value, property);
  /* TODO check for AS3_GetS successful */

  push_as3_lua_userdata(L, val);

  AS3_Release(val);

  LRETURN(L, stack, 1);
}

/*
* Set the requested property of a given ActionScript object.
* Lua example: as3.set(v, "text", "hello from Lua")
*/
static int as3_set(lua_State * L)
{
  LCALL(L, stack);

  AS3LuaUserData * userdata = NULL;
  const char * property = NULL;
  AS3_Val value;

  userdata = check_as3userdata(L, 1);

  property = lua_tostring(L, 2);
  luaL_argcheck(L, property != NULL, 2, "'property' expected");

  value = get_as3_value_from_lua_stack(L, 3);
  luaL_argcheck(L, value != AS3_Undefined(), 3, "'value' expected");

  AS3_SetS(userdata->value, property, value);
  /* TODO check if AS3_SetS sucessful */

  LRETURN(L, stack, 0);
}

/*
* Set a primitive ActionScript value (like String, Number, etc)
* Lua example: as3.assign(v, 5)
*/
static int as3_assign(lua_State * L)
{
  LCALL(L, stack);

  AS3LuaUserData * userdata = 0;
  AS3_Val value;

  userdata = check_as3userdata(L, 1);

  value = get_as3_value_from_lua_stack(L, 2);
  luaL_argcheck(L, value != AS3_Undefined(), 2, "'value' expected");

  /* TODO how to assign the value of a String, Number, int, etc? var s:String; s = "hello"; and do we care? */

  LRETURN(L, stack, 0);
}

/*
* Call a function on a given ActionScript object.
* Any return data is returned as an AS3 object
* Lua example: as3.call(v, "myFunction", "param1", param2, ...)
*/
static int as3_call(lua_State * L)
{
  LCALL(L, stack);

  SPAM(("as3_call(): begin"));

  AS3LuaUserData * userdata = NULL;
  AS3_Val params;
  const char * function_name = NULL;
  AS3_Val result;

  lua_pushnil(L); /* Hack to ensure we're not at empty stack */

  userdata = check_as3userdata(L, 1);
  function_name = lua_tostring(L, 2);
  luaL_argcheck(L, function_name != NULL, 2, "'function_name' expected");

  LCHECK(L, stack, 1);

#ifdef DO_SPAM
    /* TODO: Remove */
    lua_pushcfunction(L, as3_trace);
    lua_pushliteral(L, "AS3_CALL() ARGUMENTS");
    dump_lua_stack(L, LBASE(L, 2));
    lua_call(L, 2, 0);
#endif /* DO_SPAM */

  params = create_as3_value_from_lua_stack(L, 3, LBASE(L, stack), FALSE);

  LCHECK(L, stack, 1);

#ifdef DO_SPAM
  {
    SPAM(("as3_call(): object"));
    AS3_Trace(userdata->value);
    SPAM(("as3_call(): function name"));
    sztrace((char *)function_name);
    SPAM(("as3_call(): AS3 arguments (with format)"));
    AS3_Val a = AS3_CallTS("join", params, "StrType", ";");
    AS3_Trace(a);
    AS3_Release(a);
  }
#endif /* DO_SPAM */

  SPAM(("as3_call(): before call"));

  result = AS3_CallS(function_name, userdata->value, params);

  SPAM(("as3_call(): after call"));

  /* TODO check for function call failure, make sure to relase params */
  if (LTOP(L, stack) == 0)
  {
    /* TODO: HACK. Lua state is not usable after panic! */
    fatal_error("as3_call(): callback error detected");
  }

  LCHECK(L, stack, 1);
  lua_pop(L, 1); /* Remove our protection from empty stack */

  AS3_Release(params);

#ifdef DO_SPAM
  SPAM(("as3_call() result type"));
  AS3_Trace(AS3_Call(getQualifiedClassName_method, NULL, AS3_Array("AS3ValType", result)));
#endif /* DO_SPAM */

  push_as3_lua_userdata(L, result);

#ifdef DO_SPAM
  /* TODO: Remove */
  int top = lua_gettop(L);
  lua_pushcfunction(L, as3_trace);
  lua_pushliteral(L, "AS3_CALL()");
  dump_lua_stack(L, top);
  lua_call(L, 2, 0);
#endif /* DO_SPAM */

  AS3_Release(result);

  LRETURN(L, stack, 1);
}

/*
* Return the ActionScript qualified name of the given object as a string
* Lua example: as3.type(v)
* Loosely based on io_type() from Lua 5.1.4
*/
static int as3_type(lua_State * L)
{
  LCALL(L, stack);

  void * userdata = lua_touserdata(L, 1);
  if (userdata == NULL || !lua_getmetatable(L, 1))
  {
    lua_pushnil(L);
  }
  else
  {
    lua_getfield(L, LUA_REGISTRYINDEX, AS3LUA_METATABLE);
    if (!lua_rawequal(L, -1, -2))
    {
      lua_pop(L, 2); /* Pop AS3LUA_METATABLE and userdata metatable */
      lua_pushnil(L);
    }
    else
    {
      AS3LuaUserData * as3_userdata = NULL;
      AS3_Val result = NULL;
      AS3_Val params = NULL;

      lua_pop(L, 2); /* Pop AS3LUA_METATABLE and userdata metatable */

      as3_userdata = (AS3LuaUserData *)userdata;
      params = AS3_Array("AS3ValType", as3_userdata->value);
      result = AS3_Call(getQualifiedClassName_method, NULL, params);

      push_as3_to_lua_stack(L, result);

      AS3_Release(result);
      AS3_Release(params);
    }
  }

  LRETURN(L, stack, 1);
}

/*
* Return true if argument is AS3 value. Return nil otherwise
* Lua example: as3.isas3value(v)
*/
static int as3_isas3value(lua_State * L)
{
  LCALL(L, stack);

  if (!lua_isuserdata(L, 1) || !lua_getmetatable(L, 1))
  {
    lua_pushnil(L);
  }
  else
  {
    lua_getfield(L, LUA_REGISTRYINDEX, AS3LUA_METATABLE);
    if (!lua_rawequal(L, -1, -2))
    {
      lua_pop(L, 2); /* Pop AS3LUA_METATABLE and userdata metatable */
      lua_pushnil(L);
    }
    else
    {
      lua_pop(L, 2); /* Pop AS3LUA_METATABLE and userdata metatable */
      lua_pushboolean(L, TRUE);
    }
  }

  LRETURN(L, stack, 1);
}

/*
* Call a namespace function
* Can be used to call namespace functions
* Lua example: v = as3.namespacecall("flash.utils", "getQualifiedClassName")
*/
static int as3_namespacecall(lua_State * L)
{
  LCALL(L, stack);

  const char * namespace = NULL;
  const char * function_name = NULL;
  AS3_Val as_namespace;
  AS3_Val as_method;
  AS3_Val params;
  AS3_Val result;

  namespace = lua_tostring(L, 1);
  luaL_argcheck(L, namespace != NULL, 1, "'namespace' expected");

  function_name = lua_tostring(L, 2);
  luaL_argcheck(L, function_name != NULL, 2, "'function_name' expected");

  as_namespace = AS3_String(namespace);
  as_method = AS3_NSGetS(as_namespace, function_name);

  params = create_as3_value_from_lua_stack(L, 3, LBASE(L, stack), FALSE);

  result = AS3_Call(as_method, NULL, params);
  /* TODO check for function call failure, make sure to release as_namespace, as_method, params */

  push_as3_lua_userdata(L, result);

  AS3_Release(result);
  AS3_Release(as_namespace);
  AS3_Release(as_method);
  AS3_Release(params);

  LRETURN(L, stack, 1);
}

/*
* Print arguments to a trace()
* Adapted from Lua 5.1.4 luaB_print()
* NOTE: This function has string concatenation overhead due to forced \n in sztrace().
* If there is a fputs() analog, use it (and rewrite this function again, based on luaB_print).
* Lua example: as3.trace("Hello", "from Lua Alchemy")
* NOTE: This function made public to enable debugging logging from outer modules.
*/
int as3_trace(lua_State * L)
{
  LCALL(L, stack);
  int i;
  int n = LBASE(L, stack);

  luaL_Buffer b;
  luaL_buffinit(L, &b);

  lua_pushcfunction(L, luaB_tostring);
  for (i = 1; i <= n; i++)
  {
    if (i > 1)
    {
      luaL_addchar(&b, ' ');
    }

    const char * s = NULL;
    lua_pushvalue(L, -1);  /* function to be called */
    lua_pushvalue(L, i);   /* value to print */
    lua_call(L, 1, 1);
    s = lua_tostring(L, -1);  /* get result */
    if (s == NULL)
    {
      return luaL_error(
          L,
          LUA_QL("tostring") " must return a string to " LUA_QL("as3.trace")
        );
    }

    luaL_addvalue(&b);
  }

  luaL_pushresult(&b);
  sztrace((char *)lua_tostring(L, -1)); /* WARNING: Beware of embedded zeroes */
  lua_pop(L, 2); /* Pop concatenated string and luaB_tostring function */

  LRETURN(L, stack, 0);
}

/*
* Convert Lua value to AS3 type.
* Supports multiple arguments.
* If argument is an AS3 value, it is returned intact.</p>
* Lua example: as3.toas3(v)
*/
static int as3_toas3(lua_State * L)
{
  LCALL(L, stack);

  lua_getfield(L, LUA_REGISTRYINDEX, AS3LUA_METATABLE);

  int i = 1;
  for (i = 1; i <= LBASE(L, stack); ++i)
  {
    /* Note: we must push userdata, push_as3_to_lua_stack() wouldn't do it
     * since it does autoconversions.
     */

    int t = lua_type(L, i);
    if (t != LUA_TUSERDATA)
    {
      push_as3_lua_userdata(L, get_as3_value_from_lua_stack_type(L, i, t));
    }
    else
    {
      /* We have to reuse existing AS3 userdata value */
      if (!lua_getmetatable(L, i))
      {
        /* This userdata does not have metatable */
        push_as3_lua_userdata(L, as3_value_from_foreign_userdata(L, i));
      }
      else
      {
        if (!lua_rawequal(L, -1, -2))
        {
          /* This userdata has foreign metatable */
          lua_pop(L, 1); /* Pop userdata metatable */
          push_as3_lua_userdata(L, as3_value_from_foreign_userdata(L, i));
        }
        else
        {
          /* This is our AS3 userdata, reuse it */
          lua_pop(L, 1); /* Pop userdata metatable */
          lua_pushvalue(L, i);
        }
      }
    }
  }

  lua_remove(L, LBASE(L, stack) + 1); /* Remove AS3LUA_METATABLE metatable */

  LRETURN(L, stack, LBASE(L, stack));
}

/*
* AS function registry for Lua
*/
static const luaL_reg AS3_LUA_LIB[] =
{
  { "flyield", as3_flyield },
  { "stage", as3_stage },
  { "newclass", as3_newclass },
  { "new", as3_new },
  { "release", as3_release },
  { "tolua", as3_tolua },
  { "get", as3_get },
  { "set", as3_set },
  { "assign", as3_assign },
  { "call", as3_call },
  { "type", as3_type },
  { "namespacecall", as3_namespacecall },
  { "trace", as3_trace },
  { "newclass2", as3_newclass2 },
  { "new2", as3_new2 },
  { "isas3value", as3_isas3value },
  { "toas3", as3_toas3 },

  { NULL, NULL } /* The end */
};

void register_as3_lua_interface(lua_State * L)
{
  luaL_newmetatable(L, AS3LUA_METATABLE);
  lua_pushcfunction(L, as3_release);
  lua_setfield(L, -2, "__gc");
  lua_pop(L, 1); /* pop as3 metatable created above */

  /* TODO call? LCHECK_FN(L, stack, 0, fatal_error); */

  luaL_register(L, "as3", AS3_LUA_LIB);
  lua_pop(L, 1); /* pop as3 library table created by above call */
}
