package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  public class SugarLuaAlchemyTestCase extends CommonLuaAlchemyTestCase
  {
    override protected function setUp():void
    {
      myLuaAlchemy = new LuaAlchemy();
    }
  }
}
