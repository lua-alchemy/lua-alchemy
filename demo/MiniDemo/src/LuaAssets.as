package
{
  import cmodule.lua_wrapper.CLibInit;
  import flash.utils.ByteArray;

  public class LuaAssets
  {
    [Embed(source="../assets/demo.lua", mimeType="application/octet-stream")]
    private static var _demoLuaClass:Class;

    private static var _embeddedLuaFiles:Array = [
      { path:"demo.lua", asset:_demoLuaClass },
    ];

    public static function init():void
    {
      const libInitializer:CLibInit = new CLibInit();
      var luaFile:Object;
      for each (luaFile in _embeddedLuaFiles)
      {
        var luaAsset:ByteArray = new luaFile.asset() as ByteArray;
        libInitializer.supplyFile(luaFile.path, luaAsset);
      }
    }
  }
}
