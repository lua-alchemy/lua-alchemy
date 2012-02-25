package wrapperSuite.tests
{
  import flash.utils.ByteArray;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestReentrance extends SugarLuaAlchemyTestCase
  {
    // Sanity check to make sure we still understand what is going on.
    public function testDoStringInSeparateState():void
    {
      var script:String = ( <![CDATA[
        local lua = as3.class.luaAlchemy.LuaAlchemy.new()
        return lua.doString([[return 42]])
      ]]> ).toString();

      doString(script, [ true, [true, 42] ]);
    }

    public function testDoStringReentrance():void
    {
      myLuaAlchemy.setGlobal("_ALCHEMY", myLuaAlchemy);

      var script:String = ( <![CDATA[
        return _ALCHEMY.doString([[return 42]])
      ]]> ).toString();

      doString(script, [ true, [true, 42] ]);
    }

    // Sanity check to make sure we still understand what is going on.
    public function testDoFileInSeparateState():void
    {
      var script:String = ( <![CDATA[
        local lua = as3.class.luaAlchemy.LuaAlchemy.new()
        local bytes = as3.class.flash.utils.ByteArray.new()
        bytes.writeMultiByte([[return 42]], "UTF-8")
        lua.supplyFile("test://foo.lua", bytes)
        return lua.doFile("test://foo.lua")
      ]]> ).toString();

      doString(script, [ true, [true, 42] ]);
    }

    public function testDoFileReentrance():void
    {
      myLuaAlchemy.setGlobal("_ALCHEMY", myLuaAlchemy);

      var script_1:String = ( <![CDATA[
        return _ALCHEMY.doFile("test://two.lua")
      ]]> ).toString();
      var one:ByteArray = new ByteArray();
      one.writeUTFBytes(script_1);
      myLuaAlchemy.supplyFile("test://one.lua", one)

      var script_2:String = ( <![CDATA[
        return 42
      ]]> ).toString();
      var two:ByteArray = new ByteArray();
      two.writeUTFBytes(script_2);
      myLuaAlchemy.supplyFile("test://two.lua", two)

      doFile("test://one.lua", [ true, [true, 42] ]);
    }

    // Note that *Async functions are not reentrant.
    // See: http://code.google.com/p/lua-alchemy/issues/detail?id=154
  }
}
