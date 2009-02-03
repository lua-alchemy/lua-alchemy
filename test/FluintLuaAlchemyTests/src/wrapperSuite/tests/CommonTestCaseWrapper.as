package wrapperSuite.tests
{
  import luaAlchemy.lua_wrapper;

  import net.digitalprimates.fluint.tests.TestCase;

  public class CommonTestCaseWrapper extends BaseTestCase
  {
    protected var luaState:uint;

    override protected function setUp():void
    {
      luaState = lua_wrapper.luaInitilizeState();
    }

    override protected function tearDown():void
    {
      trace("CommonTestCaseWrapper::tearDown(): begin");
      try
      {
        lua_wrapper.luaClose(luaState);
      }
      catch (errObject:Error)
      {
        trace("CommonTestCaseWrapper::tearDown(): error " + errObject.message);
        throw errObject;
      }
      trace("CommonTestCaseWrapper::tearDown(): end");
    }

    protected function doString(script:String, expected:Array, verifyLength:Boolean = true):void
    {
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      checkLuaResult(expected, stack, verifyLength);
    }
  }
}
