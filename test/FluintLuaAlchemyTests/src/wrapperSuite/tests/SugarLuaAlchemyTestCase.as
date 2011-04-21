package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  public class SugarLuaAlchemyTestCase extends CommonLuaAlchemyTestCase
  {
    override protected function setUp():void
    {
      super.setUp();

      // We want sugar.
      checkLuaResult(
          [true],
          myLuaAlchemy.doFile("builtin://lua_alchemy.lua"),
          true
        );
    }
  }
}
