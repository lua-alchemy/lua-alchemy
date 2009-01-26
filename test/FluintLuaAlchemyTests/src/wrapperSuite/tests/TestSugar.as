package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  import mx.containers.Canvas;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestSugar extends CommonLuaAlchemyTestCase
  {
    public function testNewInstance():void
    {
      var script:String = ( <![CDATA[
        local v = as3.class.wrapperSuite.tests.TestWrapperHelper.new()
        return as3.type(v)
      ]]> ).toString();

      doString(script, [true, "wrapperSuite.tests::TestWrapperHelper"]);
    }

    public function testSetGetInstance():void
    {
      var script:String = ( <![CDATA[
        local v = as3.class.wrapperSuite.tests.TestWrapperHelper.new()
        v.string2 = "hello"
        return as3.tolua(v.string2)
      ]]> ).toString();

      doString(script, [true, "hello"]);
    }

    public function testCallInstanceNoReturn():void
    {
      var script:String = ( <![CDATA[
        local v = as3.class.wrapperSuite.tests.TestWrapperHelper.new()
        v.setNameAge("OldDude", 999)
        return as3.tolua(v.nameAge)
      ]]> ).toString();

      doString(script, [true, "Name: OldDude age: 999"]);
    }

    public function testCallInstanceReturnNumber():void
    {
      var script:String = ( <![CDATA[
        local v = as3.class.wrapperSuite.tests.TestWrapperHelper.new()
        return v.addTwoNumbers(13, 5)
      ]]> ).toString();

      doString(script, [true, 18]);
    }

    public function testClassStaticClass():void
    {
      var script:String = ( <![CDATA[
        return as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.class().TEST_WRAPPER_HELPER_EVENT)
      ]]> ).toString();

      doString(script, [true, "TestWrapperHelperEvent"]);
    }

    public function testClassStaticNoClass():void
    {
      var script:String = ( <![CDATA[
        return as3.tolua(as3.class.wrapperSuite.tests.TestWrapperHelper.TEST_WRAPPER_HELPER_EVENT)
      ]]> ).toString();

      doString(script, [true, "TestWrapperHelperEvent"]);
    }

    public function testClassVar():void
    {
      var script:String = ( <![CDATA[
        local v = as3.class.String.class()
        return as3.type(v)
      ]]> ).toString();

      doString(script, [true, "String"]);
    }

    public function testClassStaticFunctionWithReturnClass():void
    {
      var script:String = ( <![CDATA[
        local r = as3.class.wrapperSuite.tests.TestWrapperHelper.class().staticNameAge("Bubba Joe Bob Brain", 7)
        return as3.tolua(r)
      ]]> ).toString();

      doString(script, [true, "Name: Bubba Joe Bob Brain age: 7"]);
    }

    public function testClassStaticFunctionWithReturnNoClass():void
    {
      var script:String = ( <![CDATA[
        local r = as3.class.wrapperSuite.tests.TestWrapperHelper.staticNameAge("Bubba Joe Bob Brain", 7)
        return as3.tolua(r)
      ]]> ).toString();

      doString(script, [true, "Name: Bubba Joe Bob Brain age: 7"]);
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

      doString(script, [true, "Some String", "A New String"]);
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

      doString(script, [true, "Some String", "A New String"]);
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

      doString(script, [true, "Start String", "Totally different string"]);
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

      doString(script, [true, "Start String", "Totally different string"]);
    }

    public function testNamespaceFunction():void
    {
      var script:String = ( <![CDATA[
        return as3.type(as3.namespace.flash.utils.getQualifiedClassName("foo"))
      ]]> ).toString();

      doString(script, [true, "String"]);
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

      doString(script, [true]);
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

      doString(script, [true]);

      assertEquals("First line\nSecond line\n", printer.text);
    }

    public function testChainSugarCalls():void
    {
      var script:String = ( <![CDATA[
        return as3.class.String.new("Test Chain").toUpperCase().toLowerCase()
      ]]> ).toString();

      doString(script, [true, "test chain"]);
    }

    public function testChainSugarCallsOnGet():void
    {
      var script:String = ( <![CDATA[
        return as3.class.Array.new().length.toString()
      ]]> ).toString();

      doString(script, [true, "0"]);
    }

    // TODO test as3.filegetcontents(file) when loaded by default

    // TODO test with and without strict
  }
}
