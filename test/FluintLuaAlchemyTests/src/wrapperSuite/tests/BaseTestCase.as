package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  import net.digitalprimates.fluint.tests.TestCase;

  public class BaseTestCase extends TestCase
  {
    protected function checkLuaResult(expected:Array, actual:Array, verifyLength:Boolean = true):void
    {
      // Special case to enhance readability of Lua error reporting
      if (
        expected.length > 0 &&
        expected[0] == true &&
        actual.length > 1 &&
        actual[0] == false
      )
      {
        actual.shift();
        fail("Lua error: " + actual.join("\n"));
      }

      if (verifyLength)
      {
        assertEquals("stack length", expected.length, actual.length);
      }

      for (var i:int = 0; i < expected.length; ++i)
      {
        if (i == 0)
        {
          assertEquals("success code", expected[i], actual[i]);
        }
        else
        {
          assertEquals("return value #" + i, expected[i], actual[i]);
        }
      }
    }
  }
}
