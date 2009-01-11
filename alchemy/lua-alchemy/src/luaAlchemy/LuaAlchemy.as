package luaAlchemy
{
  import cmodule.lua_wrapper.CLibInit;

  public class LuaAlchemy
  {
    private static const _libInit:cmodule.lua_wrapper.CLibInit = new cmodule.lua_wrapper.CLibInit();
    private static const _luaAssetInit:* = LuaAssets.init(_libInit);

    private var luaState:uint;

    public function LuaAlchemy()
    {
    }

    public function init(luaCanvas:*):void
    {
      if (luaState != 0) close();
      luaState = lua_wrapper.luaInitilizeState();

      // TODO break sugar's dependency on having a canvas, which is a Flex object
      lua_wrapper.setGlobal(luaState, "_LUA_ALCHEMY_CANVAS", luaCanvas);
      lua_wrapper.setGlobal(luaState, "_LUA_ALCHEMY_FILESYSTEM_ROOT", LuaAssets.filesystemRoot());

      var stack:Array = lua_wrapper.doFile(luaState, "builtin://lua_alchemy.lua");
      if (stack.shift() == false)
      {
        close();
        throw new Error("LuaAlchemy.init() failed to call 'lua_alchemy.lua': " + stack.toString());
      }
    }

    public function close():void
    {
      if (luaState != 0)
      {
        lua_wrapper.luaClose(luaState);
        luaState = 0;
      }
    }

    public function doFile(strFileName:String):Array
    {
      if (luaState == 0) throw new Error("Call init() first.");
      return lua_wrapper.doFile(luaState, strFileName);
    }

    public function doString(strValue:String):Array
    {
      if (luaState == 0) throw new Error("Call init() first.");
      return lua_wrapper.luaDoString(luaState, strValue);
    }

    public function setGlobal(key:String, value:*):void
    {
      if (luaState == 0) throw new Error("Call init() first.");
      lua_wrapper.setGlobal(luaState, key, value);
    }
  }
}
