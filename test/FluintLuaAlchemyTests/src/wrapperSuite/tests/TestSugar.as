package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  import mx.containers.Canvas;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestSugar extends TestCase
  {
    protected var myLuaAlchemy:LuaAlchemy;
    protected static var v:TestWrapperHelper; // Make sure the TestWrapperHelper is included so sugar can make it even when the other tests are compiled out

    override protected function setUp():void
    {
      myLuaAlchemy = new LuaAlchemy();
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
        local v = as3.class.wrapperSuite.tests.TestWrapperHelper.new()
        return as3.type(v)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("wrapperSuite.tests::TestWrapperHelper", stack[1]);
    }

    public function testSetGetInstance():void
    {
      var script:String = ( <![CDATA[
        local v = as3.class.wrapperSuite.tests.TestWrapperHelper.new()
        v.string2 = "hello"
        return as3.tolua(v.string2)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("hello", stack[1]);
    }

    public function testCallInstanceNoReturn():void
    {
      var script:String = ( <![CDATA[
        local v = as3.class.wrapperSuite.tests.TestWrapperHelper.new()
        v.setNameAge("OldDude", 999)
        return as3.tolua(v.nameAge)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("Name: OldDude age: 999", stack[1]);
    }

    public function testCallInstanceReturnNumber():void
    {
      var script:String = ( <![CDATA[
        local v = as3.class.wrapperSuite.tests.TestWrapperHelper.new()
        return v.addTwoNumbers(13, 5)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals(18, stack[1]);
    }

    public function testClassStaticClass():void
    {
      var script:String = ( <![CDATA[
        return as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.class().TEST_WRAPPER_HELPER_EVENT)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("TestWrapperHelperEvent", stack[1]);
    }

    public function testClassStaticNoClass():void
    {
      var script:String = ( <![CDATA[
        return as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.TEST_WRAPPER_HELPER_EVENT)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("TestWrapperHelperEvent", stack[1]);
    }

    public function testClassVar():void
    {
      var script:String = ( <![CDATA[
        local v = as3.class.String.class()
        return as3.type(v)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("String", stack[1]);
    }

    public function testClassStaticFunctionWithReturnClass():void
    {
      var script:String = ( <![CDATA[
        local r = as3.class.wrapperSuite.tests.TestWrapperHelper.class().staticNameAge("Bubba Joe Bob Brain", 7)
        return as3.tolua(r)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("Name: Bubba Joe Bob Brain age: 7", stack[1]);
    }

    public function testClassStaticFunctionWithReturnNoClass():void
    {
      var script:String = ( <![CDATA[
        local r = as3.class.wrapperSuite.tests.TestWrapperHelper.staticNameAge("Bubba Joe Bob Brain", 7)
        return as3.tolua(r)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("Name: Bubba Joe Bob Brain age: 7", stack[1]);
    }

    public function testClassSetStaticVarClass():void
    {
      TestWrapperHelper.staticString = "Some String"
      var script:String = ( <![CDATA[
        local oldStr = as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.class().staticString)
        as3.class.wrapperSuite.tests.TestWrapperHelper.class().staticString = "A New String"
        local newStr = as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.class().staticString)
        return oldStr, newStr
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("Some String", stack[1]);
      assertEquals("A New String", stack[2]);
    }

    public function testClassSetStaticVarNoClass():void
    {
      TestWrapperHelper.staticString = "Some String"
      var script:String = ( <![CDATA[
        local oldStr = as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.staticString)
        as3.class.wrapperSuite.tests.TestWrapperHelper.staticString = "A New String"
        local newStr = as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.staticString)
        return oldStr, newStr
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("Some String", stack[1]);
      assertEquals("A New String", stack[2]);
    }

    public function testClassStaticFunctionNoReturnClass():void
    {
      TestWrapperHelper.staticString = "Start String"
      var script:String = ( <![CDATA[
        local oldStr = as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.class().staticString)
        as3.class.wrapperSuite.tests.TestWrapperHelper.class().setStaticString("Totally different string")
        local newStr = as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.class().staticString)
        return oldStr, newStr
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("Start String", stack[1]);
      assertEquals("Totally different string", stack[2]);
    }

    public function testClassStaticFunctionNoReturnNoClass():void
    {
      TestWrapperHelper.staticString = "Start String"
      var script:String = ( <![CDATA[
        local oldStr = as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.staticString)
        as3.class.wrapperSuite.tests.TestWrapperHelper.setStaticString("Totally different string")
        local newStr = as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.staticString)
        return oldStr, newStr
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("Start String", stack[1]);
      assertEquals("Totally different string", stack[2]);
    }

    public function testNamespaceFunction():void
    {
      var script:String = ( <![CDATA[
        return as3.type(as3.namespace.flash.utils.getQualifiedClassName("foo"))
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("String", stack[1]);
    }

    public function testOnClose():void
    {
      TestWrapperHelper.staticString = "Start String"
      var script:String = ( <![CDATA[
        as3.onclose(
          function()
            as3.class.wrapperSuite.tests.TestWrapperHelper.staticString = "Closed"
          end)
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals(1, stack.length)
      assertEquals("Start String", TestWrapperHelper.staticString);

      myLuaAlchemy.close()
      assertEquals("Closed", TestWrapperHelper.staticString);
    }

    public function testMakePrinter():void
    {
      var printer:Object = new Object();
      printer.text = "First line\n";
      myLuaAlchemy.setGlobal("printer", printer);

      var script:String = ( <![CDATA[
        print = as3.makeprinter(printer)
        print("Second line")
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);

      assertTrue(stack[0]);
      assertEquals(1, stack.length);

      assertEquals("First line\nSecond line\n", printer.text);
    }

    public function testChainSugarCalls():void
    {
      var script:String = ( <![CDATA[
        return as3.class.String.new("Test Chain").toUpperCase().toLowerCase()
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("test chain", stack[1]);
    }

    public function testChainSugarCallsOnGet():void
    {
      var script:String = ( <![CDATA[
        return as3.class.Array.new().length.toString()
      ]]> ).toString();
      var stack:Array = myLuaAlchemy.doString(script);
      assertTrue(stack[0]);
      assertEquals("0", stack[1]);
    }

    // TODO test as3.filegetcontents(file) when loaded by default

    // TODO test with and without strict
  }
}
