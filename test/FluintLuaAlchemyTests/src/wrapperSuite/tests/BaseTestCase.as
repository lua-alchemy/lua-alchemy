package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  import net.digitalprimates.fluint.tests.TestCase;

  public class BaseTestCase extends TestCase
  {
    protected function checkLuaResult(
        expected:Array,
        actual:Array,
        verifyLength:Boolean = true,
        errorPrefix:String = ""
      ):void
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
        fail(errorPrefix + "Lua error: " + actual.join("\n"));
      }

      for (var i:int = 0; i < expected.length; ++i)
      {
        // Hack?
        if (expected[i] is Array && actual[i] is Array)
        {
          checkLuaResult(
              expected[i],
              actual[i],
              true,
              "sub-result " + i + ": "
            );
        }
        else if (i == 0)
        {
          assertEquals(errorPrefix + "success code", expected[i], actual[i]);
        }
        else
        {
          assertEquals(
              errorPrefix + "return value #" + i, expected[i], actual[i]
            );
        }
      }

      if (verifyLength)
      {
        assertEquals(
            errorPrefix + "stack length", expected.length, actual.length
          );
      }
    }
  }
}
