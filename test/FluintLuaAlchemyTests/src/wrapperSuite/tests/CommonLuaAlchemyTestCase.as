package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  import net.digitalprimates.fluint.tests.TestCase;

  public class CommonLuaAlchemyTestCase extends TestCase
  {
    protected var myLuaAlchemy:LuaAlchemy;

    override protected function setUp():void
    {
      myLuaAlchemy = new LuaAlchemy();
    }

    override protected function tearDown():void
    {
      trace("TestLuaAlchemyInterface::tearDown(): begin");
      try
      {
        myLuaAlchemy.close();
        myLuaAlchemy = null;
      }
      catch (errObject:Error)
      {
        trace("TestLuaAlchemyInterface::tearDown(): error " + errObject.message);
        throw errObject;
      }
      trace("TestLuaAlchemyInterface::tearDown(): end");
    }

    protected function checkLuaResult(expected:Array, actual:Array, verifyLength:Boolean = true):void
    {
      if (verifyLength)
      {
        assertEquals("stack length", expected.length, actual.length);
      }

      for (var i:int = 0; i < expected.length; ++i)
      {
        if (i == 0)
        {
          assertEquals("success code", expected[i], actual[i]);
        }
        else
        {
          assertEquals("return value #" + i, expected[i], actual[i]);
        }
      }
    }

    protected function doString(script:String, expected:Array, verifyLength:Boolean = true):void
    {
      var stack:Array = myLuaAlchemy.doString(script);
      checkLuaResult(expected, stack, verifyLength);
    }
  }
}
