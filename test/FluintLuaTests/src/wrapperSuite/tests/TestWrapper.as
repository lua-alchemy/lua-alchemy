package wrapperSuite.tests
{
	import luaalchemy.lua_wrapper;
	
	import net.digitalprimates.fluint.tests.TestCase;

	public class TestWrapper extends TestCase
	{
		public function TestWrapper()
		{
			super();
		}
		
		public function testCreateCloseContext():void
		{
			var luaCtx:uint = lua_wrapper.luaCreateContext();
			assertTrue(luaCtx != 0);
			lua_wrapper.luaClose(luaCtx);
		}
		
		public function testDoScriptAdd():void
		{
			var luaCtx:uint = lua_wrapper.luaCreateContext();
			
			var stack:Array = lua_wrapper.luaDoString(luaCtx, "return 1+5");
			assertEquals(1, stack.length);
			assertEquals(stack[0], "6");
			
			lua_wrapper.luaClose(luaCtx);
		}

		public function testAS3Class():void
		{
		}
		
		public function testAS3New():void 
		{
		}
		 		
		public function testAS3Release():void
		{
		}
		 
		public function testAS3Get():void
		{
		}
		
		public function testAS3Set():void
		{
		}
		
		public function testAS3Call():void
		{
		}
		
		public function testAS3Yield():void
		{
		}
		
		public function testAS3Stage():void
		{
		}
		
	}
}