package wrapperSuite.tests
{
  import luaAlchemy.lua_wrapper;

  import net.digitalprimates.fluint.tests.TestCase;

  public class CommonTestCase extends TestCase
  {
    protected var luaState:uint;
    override protected function setUp():void
    {
      luaState = lua_wrapper.luaInitilizeState();
    }

    override protected function tearDown():void
    {
      trace("TestWraper::tearDown(): begin");
      try
      {
        lua_wrapper.luaClose(luaState);
      }
      catch (errObject:Error)
      {
        trace("TestWrapper::tearDown(): error " + errObject.message);
        throw errObject;
      }
      trace("TestWraper::tearDown(): end");
    }
  }
}