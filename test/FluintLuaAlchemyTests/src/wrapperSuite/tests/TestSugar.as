package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;
  import luaAlchemy.LuaAssets;

  import mx.containers.Canvas;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestSugar extends TestCase
  {
      protected var myLuaAlchemy:LuaAlchemy;
      protected var canvas:Canvas = new Canvas();

      override protected function setUp():void
      {
        myLuaAlchemy = new LuaAlchemy();
        myLuaAlchemy.init(canvas);
      }

      override protected function tearDown():void
      {
        trace("TestSugar::tearDown(): begin");
        try
        {
          myLuaAlchemy.close();
          myLuaAlchemy = null;
        }
        catch (errObject:Error)
        {
          trace("TestSugar::tearDown(): error " + errObject.message);
          throw errObject;
        }
        trace("TestSugar::tearDown(): end");
      }

      public function testNewInstance():void
      {
        var script:String = ( <![CDATA[
          v = as3.wrapperSuite.tests.TestWrapperHelper.new()
          return as3.type(v)
        ]]> ).toString();
        var stack:Array = myLuaAlchemy.doString(script);
        assertTrue(stack[0]);
        assertEquals("wrapperSuite.tests::TestWrapperHelper", stack[1]);
      }

      public function testSetGetInstance():void
      {
        var script:String = ( <![CDATA[
          v = as3.wrapperSuite.tests.TestWrapperHelper.new()
          v.string2 = "hello"
          return v.string2
        ]]> ).toString();
        var stack:Array = myLuaAlchemy.doString(script);
        assertTrue(stack[0]);
        assertEquals("hello", stack[1]);
      }

      public function testCallInstanceNoReturn():void
      {
        var script:String = ( <![CDATA[
          v = as3.wrapperSuite.tests.TestWrapperHelper.new()
          v.setNameAge("OldDude", 999)
          return v.nameAge
        ]]> ).toString();
        var stack:Array = myLuaAlchemy.doString(script);
        assertTrue(stack[0]);
        assertEquals("Name: OldDude age: 999", stack[1]);
      }
  }
}
