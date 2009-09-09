package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  import flash.utils.ByteArray;

  import mx.containers.Canvas;
  import mx.utils.ObjectUtil;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestLuaBased extends CommonLuaAlchemyTestCase
  {
    override protected function setUp():void
    {
      // Using own LuaAssets here.
      LuaAssets.init(LuaAlchemy.libInit);
      myLuaAlchemy = new LuaAlchemy(LuaAssets.filesystemRoot());
    }

    // TODO: Hack. Should be in Alchemy interface.
    //       Should accept varargs
    protected function doFileArgs(expected:Array, file:String, args:String):void
    {
      // TODO: Quote strings
      doString("assert(loadfile('"+file+"'))("+args+")", expected);
    }

    public function testLuaNucleoSuite():void
    {
      doFileArgs([true], "builtin://test-lua-nucleo.lua", "'suite'");
    }
  }
}
