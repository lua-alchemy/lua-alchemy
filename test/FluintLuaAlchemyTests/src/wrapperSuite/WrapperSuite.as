package wrapperSuite
{
  import net.digitalprimates.fluint.tests.TestSuite;

  import wrapperSuite.tests.*;

  public class WrapperSuite extends TestSuite
  {
    public function WrapperSuite()
    {
      addTestCase(new TestWrapper());
      addTestCase(new TestAS3LuaInterface());
      addTestCase(new TestTypeConversion());
      addTestCase(new TestCallbacks());
      addTestCase(new TestSugar());
      addTestCase(new TestLuaAlchemyInterface());
      addTestCase(new TestStrictness());
      addTestCase(new TestLuaBased());
    }
  }
}
