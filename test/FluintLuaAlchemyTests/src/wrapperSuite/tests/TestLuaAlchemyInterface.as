package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;
  import flash.utils.ByteArray;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestLuaAlchemyInterface extends TestCase
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

    public function testInit():void
    {
      assertTrue(false);
    }

    public function testClose():void
    {
      assertTrue(false);
    }

    public function testDoString():void
    {
      assertTrue(false);
    }

    public function testDoFile():void
    {
      var script:String = ( <![CDATA[
        return 42
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);

      myLuaAlchemy.supplyFile("myFileDoFileNoError.lua", luaAsset);
      var stack:Array = myLuaAlchemy.doFile("myFileDoFileNoError.lua");

      assertTrue(stack[0]);
      assertEquals(42, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testSetGlobal():void
    {
      assertTrue(false);
    }

    public function testSetGlobalLuaValue():void
    {
      assertTrue(false);
    }

  }
}