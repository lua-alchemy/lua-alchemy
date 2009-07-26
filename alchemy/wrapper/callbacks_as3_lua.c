/* callbacks_as3_lua.h -- Handle creation and management of Lua function callbacks returned on stack
 */
#include "callbacks_as3_lua.h"

#include <lauxlib.h>
/*#include <lualib.h>*/

#include "lua-alchemy.h"
#include "lstack.h"
#include "bridge_lua_c.h"
#include "bridge_as3_lua.h"

#ifdef DO_SPAM

#include "bridge_as3_c.h"
#include "as3_lua_interface.h"

#endif /* DO_SPAM */

typedef struct LuaFunctionCallbackData
{
  lua_State * L;
  int ref;
  AS3_Val as3Function;
} LuaFunctionCallbackData;

#define AS3LUA_CBFNINDEX (1)
#define AS3LUA_CBSDATAINDEX (2)

static AS3_Val as3_lua_callback(void * data, AS3_Val args);
AS3_Val as3_lua_callback(void * data, AS3_Val args);
static int release_callback(lua_State * L);

void initialize_callbacks(lua_State * L)
{
  luaL_newmetatable(L, AS3LUA_CALLBACKMT);
  lua_pushcfunction(L, release_callback);
  lua_setfield(L, -2, "__gc");
  lua_pop(L, 1); /* pop callback metatable created above */

  /* TODO call? LCHECK_FN(L, stack, 0, fatal_error); */

  lua_newtable(L);
  lua_setfield(L, LUA_REGISTRYINDEX, AS3LUA_CALLBACKS);
}

/*
* Function used as a callback for all Lua functions passed through
* get_as3_value_from_lua_stack()
*/
AS3_Val as3_lua_callback(void * data, AS3_Val args)
{
  /* WARNING: Panic alert! Use L*_FN checkers here! */

  SPAM(("as3_lua_callback(): begin"));

  AS3_Val res;
  LuaFunctionCallbackData * func_data = (LuaFunctionCallbackData *) data;
  int nargs = 0;
  int status = 0;
  int results_base = 0;
  lua_State * L = func_data->L;
  if (L == NULL)
  {
    /* TODO: Should we crash here?
    fatal_error("state expired"); / * Does not return * /
    */
    sztrace("as3_lua_callback: state expired");
    return AS3_Undefined();
  }

  { /* A new scope for LCALL to work (C89 conformance) */
    LCALL(L, stack);

    /* TODO: Cache that with lua_ref, it is faster */
    lua_getfield(L, LUA_REGISTRYINDEX, AS3LUA_CALLBACKS);

    /* TODO: Assert we have a table here */

    lua_rawgeti(L, -1, func_data->ref); /* push stored function */

    if (lua_istable(L, -1) == 0) /* Probably nil */
    {
      lua_pop(L, 1); /* Pop bad callback table */
      LCHECK_FN(L, stack, 0, fatal_error);

      fatal_error("function callback not found"); /* Does not return */
    }

    lua_rawgeti(L, -1, AS3LUA_CBFNINDEX); /* push stored callback function */

 #ifdef DO_SPAM
  {
    SPAM(("as3_lua_callback(): AS3 arguments"));
    AS3_Val a = AS3_CallS("join", args, AS3_Undefined());
    AS3_Trace(a);
    AS3_Release(a);
  }
#endif /* DO_SPAM */


    /* TODO: Assert we have Lua function (or other callable object) on the top of the stack */

    LCHECK_FN(L, stack, 2 + 1, fatal_error);

    nargs = push_as3_array_to_lua_stack(L, args); /* push arguments */

#ifdef DO_SPAM
    /* TODO: Remove */
    lua_pushcfunction(L, as3_trace);
    dump_lua_stack(L, LBASE(L, stack) + 2 + 1);
    lua_pushliteral(L, "ARGUMENTS");
    lua_pushnumber(L, nargs);
    lua_call(L, 3, 0);
#endif /* DO_SPAM */

    LCHECK_FN(L, stack, 2 + 1 + nargs, fatal_error);

    results_base = LBASE(L, stack) + 2;
    status = do_pcall_with_traceback(L, nargs, LUA_MULTRET);
    if (status != 0)
    {
      const char * msg = NULL;

      LCHECK_FN(L, stack, 2 + 1, fatal_error); /* Tables and error message */
      lua_remove(L, -2); /* Remove AS3LUA_CALLBACKS table */
      lua_remove(L, -2); /* Remove holder table */
      LCHECK_FN(L, stack, 1, fatal_error); /* Only error message */

      /* Error message is on stack */
      /* NOTE: It is not necessary string! If we want to preserve its type, see lua_DoString. */

      if (lua_tostring(L, -1) == NULL)
      {
        lua_pop(L, 1);
        lua_pushliteral(L, "(non-string)");
      }

      LCHECK_FN(L, stack, 1, fatal_error);

      lua_pushliteral(L, "Error in Lua callback:\n");
      lua_insert(L, -2);

      LCHECK_FN(L, stack, 2, fatal_error);

      lua_concat(L, 2);

      LCHECK_FN(L, stack, 1, fatal_error);

      sztrace((char *)lua_tostring(L, -1));

      /* TODO: ?! */
      /* lua_error(L); */

      msg = lua_tostring(L, -1);
      lua_pop(L, 1);

/*
      fatal_error(msg); / * Does not return * /
*/
    }

    /* Process results */

#ifdef DO_SPAM
    /* TODO: Remove */
    /*
    lua_pushcfunction(L, as3_trace);
    lua_pushliteral(L, "STACK");
    dump_lua_stack(L, results_base);
    lua_call(L, 2, 0);
    */
#endif /* DO_SPAM */

    res = create_as3_value_from_lua_stack(L, results_base + 1, LTOP(L, stack), TRUE);

#ifdef DO_SPAM
    SPAM(("as3_lua_callback() result type"));
    AS3_Trace(AS3_Call(getQualifiedClassName_method, NULL, AS3_Array("AS3ValType", res)));
#endif /* DO_SPAM */

    lua_settop(L, LBASE(L, stack)); /* Cleanup results and two holder tables */

    SPAM(("as3_lua_callback(): end"));

    return res;
  }

  /* Unreachable */
}

int release_callback(lua_State * L)
{
  SPAM(("release_callback() : begin"));

  LuaFunctionCallbackData ** pUserdata = (LuaFunctionCallbackData **)luaL_checkudata(
      L, 1, AS3LUA_CALLBACKMT
    );
  if (pUserdata == NULL)
  {
    SPAM(("release_callback() : bad userdata"));
    return 0;
  }

  LuaFunctionCallbackData * pCallback = *pUserdata;
  if (pCallback == NULL)
  {
    SPAM(("release_callback() : bad callback"));
    return 0;
  }

  if (pCallback->L != NULL)
  {
    if (pCallback->as3Function != AS3_Undefined())
    {
      SPAM(("release_callback() : before release"));
      AS3_Release(pCallback->as3Function);
      SPAM(("release_callback() : after release"));
      pCallback->as3Function = AS3_Undefined();
    }

    pCallback->L = NULL;
  }

  *pUserdata = NULL;

  SPAM(("release_callback() : end"));

  return 0;
}

AS3_Val setup_callback(lua_State * L, int index)
{
  LCALL(L, stack);

  SPAM(("setup_callback() : begin"));

  AS3_Val as3Function;
  int ref = 0;
  LuaFunctionCallbackData ** pUserdata = NULL;

  /*
    NOTE: Can't do lua_newuserdata() immediately
          since it would be deleted by Lua on lua_close()
  */
  /* TODO: Free this somewhere! When freeing, remove pData->ref from the state */
  LuaFunctionCallbackData * pData = malloc(sizeof(LuaFunctionCallbackData));

  index = LABSIDX(L, stack, index); /* Normalize index */

  /* TODO: Cache that with lua_ref, it is faster */
  lua_getfield(L, LUA_REGISTRYINDEX, AS3LUA_CALLBACKS);
  /* TODO: Assert this is a table */

  lua_newtable(L);

  LCHECK(L, stack, 2);

  lua_pushvalue(L, index); /* Store function */
  lua_rawseti(L, -2, AS3LUA_CBFNINDEX);

  LCHECK(L, stack, 2);

  pUserdata = lua_newuserdata(L, sizeof(LuaFunctionCallbackData *));
  *pUserdata = pData;

  luaL_getmetatable(L, AS3LUA_CALLBACKMT);
  lua_setmetatable(L, -2);
  lua_rawseti(L, -2, AS3LUA_CBSDATAINDEX);

  LCHECK(L, stack, 2);

  ref = luaL_ref(L, -2);

  LCHECK(L, stack, 1);

  lua_pop(L, 1); /* Pop AS3LUA_CALLBACKS */

  as3Function = AS3_Function(pData, as3_lua_callback);

  pData->ref = ref;
  pData->L = L;
  pData->as3Function = as3Function;

  LCHECK(L, stack, 0);

  SPAM(("setup_callback() : end"));

  return as3Function;
}

