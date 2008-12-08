package wrapperSuite.tests
{
	import flash.utils.ByteArray;
	
	import luaalchemy.lua_wrapper;
	
	import net.digitalprimates.fluint.tests.TestCase;

	public class TestWrapper extends TestCase
	{
		public function TestWrapper()
		{
			super();
		}
		
		private var luaCtx:uint;
		override protected function setUp():void {
			luaCtx = lua_wrapper.luaCreateContext();
		}
		
		override protected function tearDown():void {
			lua_wrapper.luaClose(luaCtx);
		}
		
		public function testCreateCloseContext():void
		{
			var luaCtx:uint = lua_wrapper.luaCreateContext();
			assertTrue(luaCtx != 0);
			lua_wrapper.luaClose(luaCtx);
		}
		
		public function testDoScriptAdd():void
		{
			var stack:Array = lua_wrapper.luaDoString(luaCtx, "return 1+5");
			assertEquals(1, stack.length);
			assertEquals(6, stack[0]);
		}

		public function testAS3NewArray():void 
		{
			var script:String = "v = as3.new(\"Array\")\nreturn v"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertTrue(stack[0] is Array);
		}

		public function testAS3NewByteArray():void 
		{
			var script:String = "v = as3.new(\"flash.utils.ByteArray\")\nreturn v"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertTrue(stack[0] is ByteArray);
		}

		public function testAS3Release():void
		{
			var script:String = "v = as3.new(\"flash.utils.ByteArray\")\nas3.release(v)\nreturn v"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertNull(stack[0]);
		}
		 
		public function testAS3Class():void
		{
			var script:String = "v = as3.class(\"String\")\nreturn v"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertTrue(stack[0] is Class);
		}
		
		public function testAS3Get():void
		{
			var script:String = "v = as3.new(\"Array\")\nreturn as3.get(v, \"length\")"
			var stack:Array = lua_wrapper.luaDoString(luaCtx, script);
			assertEquals(1, stack.length);
			assertTrue(stack[0] is int);
			assertEquals(0, stack[0]);
		}
		
		// TODO test getting every possible type defined in push_as3_to_lua_stack(), also check type on lua end
/*		
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
*/
	}
}