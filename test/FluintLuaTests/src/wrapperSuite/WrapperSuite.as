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
		}
		
	}
}