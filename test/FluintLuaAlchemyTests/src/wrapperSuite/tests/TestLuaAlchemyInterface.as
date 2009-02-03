package wrapperSuite.tests
{
  import flash.utils.ByteArray;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestLuaAlchemyInterface extends CommonLuaAlchemyTestCase
  {
    public function testInit():void
    {
      var scriptInit:String = ( <![CDATA[
        iTest = 5 -- intentionally a global so available to next script
        ]]> ).toString();
      var scriptAdd:String = ( <![CDATA[
        return iTest + 5
        ]]> ).toString();

      myLuaAlchemy.doString(scriptInit);
      doString(scriptAdd, [true, 10]);

      myLuaAlchemy.init();
      doString(scriptAdd, [false], false);
    }

    public function testCloseAndAutoInit():void
    {
      var scriptInit:String = ( <![CDATA[
        iTest = 5 -- intentionally a global so available to next script
        ]]> ).toString();
      var scriptAdd:String = ( <![CDATA[
        return iTest + 5
        ]]> ).toString();

      myLuaAlchemy.doString(scriptInit);
      doString(scriptAdd, [true, 10]);

      myLuaAlchemy.close();
      doString(scriptAdd, [false], false);
    }

    public function testDoString():void
    {
      var script:String = ( <![CDATA[
        return "Test doString"
        ]]> ).toString();

      doString(script, [true, "Test doString"])
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

      checkLuaResult([true, 42], stack);
    }

    public function testSetGlobal():void
    {
      myLuaAlchemy.setGlobal("hello", "Hello There");

      var script:String = ( <![CDATA[
        return hello, as3.type(hello), type(hello)
        ]]> ).toString();

      doString(script, [true, "Hello There", "String", "userdata"])
    }

    public function testSetGlobalLuaValue():void
    {
      myLuaAlchemy.setGlobalLuaValue("hello", "Hello There");

      var script:String = ( <![CDATA[
        return hello, as3.type(hello), type(hello)
        ]]> ).toString();

      doString(script, [true, "Hello There", null, "string"])
    }
  }
}