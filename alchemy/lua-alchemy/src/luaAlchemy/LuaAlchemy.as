package luaAlchemy
{
  import cmodule.lua_wrapper.CLibInit;

  /** Class calls and initializes the Lua interpreter */
  public class LuaAlchemy
  {
    /** Lua assets initializer. Exposed to allow user's assets exposure to Lua */
    public static const libInit:cmodule.lua_wrapper.CLibInit = new cmodule.lua_wrapper.CLibInit();

    private static const _luaAssetInit:* = LuaAssets.init(libInit);

    private var luaState:uint = 0;

    /**
    * Create and init() a new Lua interpreter
    * @see init()
    */
    public function LuaAlchemy()
    {
      init();
    }

    /**
    * Initialize the Lua interpreter.  If already initialized, it will be closed
    * and then initialized.
    * @see close()
    */
    public function init():void
    {
      if (luaState != 0) close();
      luaState = lua_wrapper.luaInitilizeState();

      lua_wrapper.setGlobal(luaState, "_LUA_ALCHEMY_FILESYSTEM_ROOT", LuaAssets.filesystemRoot());

      var stack:Array = lua_wrapper.doFile(luaState, "builtin://lua_alchemy.lua");
      if (stack.shift() == false)
      {
        close();
        throw new Error("LuaAlchemy.init() failed to call 'lua_alchemy.lua': " + stack.toString());
      }
    }

    /** Close the Lua interpreter and cleanup. */
    public function close():void
    {
      if (luaState != 0)
      {
        lua_wrapper.luaClose(luaState);
        luaState = 0;
      }
    }

    /**
    * Run the given file.  Returns an array of values represting
    * the results of the call.  The first return value is true/false based on
    * if the string is sucessfully run.  If sucessful, the remaining values
    * are the Lua return values.  If failed, the second value is the error.
    * Note at this time you can only run LuaAsset files.
    * @param strValue The string to run.
    * @return The Lua return call stack.
    */
    public function doFile(strFileName:String):Array
    {
      if (luaState == 0) init();
      return lua_wrapper.doFile(luaState, strFileName);
    }

    /**
    * Run the given string.  Returns an array of values represting
    * the results of the call.  The first return value is true/false based on
    * if the string is sucessfully run.  If sucessful, the remaining values
    * are the Lua return values.  If failed, the second value is the error.
    * @param strValue The string to run.
    * @return The Lua return call stack.
    */
    public function doString(strValue:String):Array
    {
      if (luaState == 0) init();
      return lua_wrapper.luaDoString(luaState, strValue);
    }

    /**
    * Set a global Lua variable with the key/value pair.
    * @param key The name of the new global variable
    * @param value The value of the new global variable
    */
    public function setGlobal(key:String, value:*):void
    {
      if (luaState == 0) init();
      lua_wrapper.setGlobal(luaState, key, value);
    }
  }
}
