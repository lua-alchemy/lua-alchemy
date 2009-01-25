package luaAlchemy
{
  import cmodule.lua_wrapper.CLibInit;
  import flash.utils.ByteArray;

  /** Class calls and initializes the Lua interpreter */
  public class LuaAlchemy
  {
    /** Lua assets initializer. Exposed to allow user's assets exposure to Lua */
    public static const libInit:cmodule.lua_wrapper.CLibInit = new cmodule.lua_wrapper.CLibInit();

    private static const _luaAssetInit:* = LuaAssets.init(libInit);

    private var luaState:uint = 0;
    private var vfsRoot:String = "builtin://";

    /**
    * Create and init() a new Lua interpreter
    * @param virtualFilesystemRoot The root of virtual file system (default "builtin://")
    * @see init()
    */
    public function LuaAlchemy(virtualFilesystemRoot:* = null)
    {
      init(virtualFilesystemRoot);
    }

    /**
    * Initialize the Lua interpreter.  If already initialized, it will be closed
    * and then initialized.
    * @param virtualFilesystemRoot The new root of virtual file system (optional)
    * @see close()
    */
    public function init(virtualFilesystemRoot:* = null):void
    {
      if (luaState != 0)
      {
        close();
      }

      if (virtualFilesystemRoot)
      {
        // Note this can not be changed once state is created
        vfsRoot = virtualFilesystemRoot;
      }

      luaState = lua_wrapper.luaInitilizeState();

      lua_wrapper.setGlobalLuaValue(luaState, "_LUA_ALCHEMY_FILESYSTEM_ROOT", vfsRoot);

      var stack:Array = lua_wrapper.doFile(luaState, "builtin://lua_alchemy.lua");
      if (stack.shift() == false)
      {
        close();
        throw new Error("LuaAlchemy.init() to call 'lua_alchemy.lua' failed: " + stack.toString());
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
      if (luaState == 0)
      {
        init();
      }
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
      if (luaState == 0)
      {
        init();
      }
      return lua_wrapper.luaDoString(luaState, strValue);
    }

    /**
    * Set a global Lua variable with the key/value pair.
    *	The value is never converted to a Lua native type.
    * @param key The name of the new global variable
    * @param value The value of the new global variable
    */
    public function setGlobal(key:String, value:*):void
    {
      if (luaState == 0)
      {
        init();
      }
      lua_wrapper.setGlobal(luaState, key, value);
    }

    /**
    * Set a global Lua variable with the key/value pair.
    * The value is converted to a native Lua type if possible.
    * @param key The name of the new global variable
    * @param value The value of the new global variable
    */
    public function setGlobalLuaValue(key:String, value:*):void
    {
      if (luaState == 0)
      {
        init();
      }
      lua_wrapper.setGlobalLuaValue(luaState, key, value);
    }

    /**
    * Supply a ByteArray as a file in Lua
    * @param name The name of the file within Lua
    * @param data The contents of the file
    */
    public function supplyFile(name:String, data:ByteArray):void
    {
      libInit.supplyFile(name, data);
    }
  }
}
