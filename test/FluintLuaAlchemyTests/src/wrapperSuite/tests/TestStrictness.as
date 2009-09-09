package wrapperSuite.tests
{
  import luaAlchemy.lua_wrapper;
  import mx.containers.Canvas;
  import net.digitalprimates.fluint.tests.TestCase;

  // Note that we intentionally do not use CommonLuaAlchemyTest
  // as we need to enable strict *before* lua_alchemy.lua is loaded.
  public class TestStrictness extends CommonTestCaseWrapper
  {
    // Note: We check here that Lua Alchemy does not create extra
    // unwanted globals during initialization.
    //
    // TODO: We should also test whole Lua Alchemy code (including C)
    // with strict ON, so we're sure Lua Alchemy does not pollute globals
    // in run-time.
    // We should also test with strict OFF as we do now, so we know that
    // we work without it, as strict module is optional.
    //
    public function testLuaAlchemyDoesNotPolluteGlobals() : void
    {
      // Lua Alchemy's strict module uses lua-nucleo's one,
      // so it needs to be able to dofile() properly.
      var stack:Array = lua_wrapper.doFile(luaState, "builtin://lua_alchemy/lua/dofile.lua");
      checkLuaResult([true], stack);

      stack = lua_wrapper.doFile(luaState, "builtin://lua_alchemy/lua/strict.lua");
      checkLuaResult([true], stack);

      stack = lua_wrapper.doFile(luaState, "builtin://lua_alchemy.lua");
      checkLuaResult([true], stack);

      // See if we're still alive (strictness errors should show up in checkLuaResult above)
      var script:String = ( <![CDATA[
        return 42
      ]]> ).toString();

      doString(script, [true, 42]);
    }
  }
}
