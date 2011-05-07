package
{
  import flash.utils.ByteArray;
  
  import luaAlchemy.LuaAlchemy;
  
  import org.flixel.FlxG;
  import org.flixel.FlxGame;
  import org.flixel.FlxGroup;
  import org.flixel.FlxSprite;
  import org.flixel.FlxState;
  import org.flixel.FlxText;
  import org.flixel.FlxTilemap;
  import org.flixel.FlxU;
  
  [SWF(width="640", height="480", backgroundColor="#000000")]
  
  public class EZPlatformerLuaAlchemy extends FlxGame
  {
    [Embed(source="../assets/PlayState.lua", mimeType="application/octet-stream")]
    private static var _playStateLuaClass:Class;
    
    public function EZPlatformerLuaAlchemy()
    {
      super(320,240,PlayState,2);
      initLua();
    }

    private function initLua():void
    {
      importClassesForLua();
      
      var luaAsset:ByteArray = new _playStateLuaClass() as ByteArray;
      var luaString:String = luaAsset.readUTFBytes(luaAsset.bytesAvailable);
      var lua:LuaAlchemy = new LuaAlchemy();
      var res:Array = lua.doString(luaString);
      if(res[0] === false)
      {
        throw new Error("Error executing lua main script")
      }
      PlayState.lua = lua;
    }

    private function importClassesForLua():void
    {
      FlxState;
      FlxTilemap;
      FlxSprite;
      FlxGroup;
      FlxText;
      FlxG;
      FlxU;
    }
  }
}
