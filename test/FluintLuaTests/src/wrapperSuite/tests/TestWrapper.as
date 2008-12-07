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
			assertEquals(stack.length, 1);
			assertEquals(stack[0], 6);
			
			lua_wrapper.luaClose(luaCtx);
		}
		
	}
}