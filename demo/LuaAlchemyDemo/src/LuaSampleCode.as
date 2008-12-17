package
{
  import mx.core.ByteArrayAsset;
  import flash.utils.ByteArray;

  public class LuaSampleCode
  {
    [Embed(source="../assets/demo.lua", mimeType="application/octet-stream")]
    private static var _defaultLuaClass:Class;
    private static var defaultLuaAsset:ByteArrayAsset = ByteArrayAsset(new _defaultLuaClass());
    [Bindable]
    public static var defaultLuaText:String = defaultLuaAsset.toString();
  }
}
