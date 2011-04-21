package
{
  import flash.display.*;
  import flash.text.*;

  import luaAlchemy.LuaAlchemy;

  [SWF(width="320", height="200", backgroundColor="0xFFFFFF", frameRate="30")]
  public class Barebones extends Sprite
  {
    private var lua:LuaAlchemy;

    public function Barebones()
    {
      lua = new LuaAlchemy();
      lua.setGlobal("SPRITE", this);

      var stack:Array = lua.doString( (<![CDATA[
        local text = as3.class.flash.text.TextField.new()
        text.autoSize = as3.class.flash.text.TextFieldAutoSize.LEFT
        text.text = "Hello from LuaAlchemy " .. _LUA_ALCHEMY
        SPRITE.addChild(text)
      ]]>).toString() );

      if (stack.shift() == false)
      {
        lua.close();
        throw new Error("Lua error: " + stack.toString());
      }
    }
  }
}
