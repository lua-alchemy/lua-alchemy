package wrapperSuite.tests
{
	public class TestWrapperHelper
	{
		public function TestWrapperHelper()
		{
		}
		
		public var string1:String;
		
		private var _string2:String;
		public function get string2():String { return _string2; }
		public function set string2(value:String):void { _string2 = value; }

	}
}