package wrapperSuite
{
	import net.digitalprimates.fluint.tests.TestSuite;
	
	import wrapperSuite.tests.TestWrapper;

	public class WrapperSuite extends TestSuite
	{
		public function WrapperSuite()
		{
			addTestCase(new TestWrapper());
		}
		
	}
}