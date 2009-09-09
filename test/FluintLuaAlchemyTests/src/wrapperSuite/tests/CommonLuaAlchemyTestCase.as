package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  public class CommonLuaAlchemyTestCase extends BaseTestCase
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

    protected function doString(script:String, expected:Array, verifyLength:Boolean = true):void
    {
      var stack:Array = myLuaAlchemy.doString(script);
      checkLuaResult(expected, stack, verifyLength);
    }

    protected function doFile(file:String, expected:Array, verifyLength:Boolean = true):void
    {
      var stack:Array = myLuaAlchemy.doFile(file);
      checkLuaResult(expected, stack, verifyLength);
    }
  }
}
