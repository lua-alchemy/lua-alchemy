package wrapperSuite.tests
{
  import flash.utils.ByteArray;

  import luaAlchemy.lua_wrapper;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestWrapper extends TestCase
  {
    public function TestWrapper()
    {
      super();
    }

    private var luaState:uint;
    override protected function setUp():void {
      luaState = lua_wrapper.luaInitilizeState();
    }

    override protected function tearDown():void {
      lua_wrapper.luaClose(luaState);
    }

    public function testCreateCloseContext():void
    {
      var luaState:uint = lua_wrapper.luaInitilizeState();
      assertTrue(luaState != 0);
      lua_wrapper.luaClose(luaState);
    }

    public function testDoScriptAdd():void
    {
      var script:String = ( <![CDATA[
        return 1+5
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      assertEquals(6, stack[0]);
    }

    public function testAS3NewArray():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("Array")
        return v
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      assertTrue(stack[0] is Array);
    }

    public function testAS3NewByteArray():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("flash.utils::ByteArray")
        return v
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      assertTrue(stack[0] is ByteArray);
    }

    public function testAS3Release():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("flash.utils::ByteArray")
        as3.release(v)
        return v
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      assertNull(stack[0]);
    }

    public function testAS3ToLuaTypeNumber():void
    {
      var script:String = ( <![CDATA[
        n1 = as3.new("int", 7)
        n2 = as3.new("Number", 6)
        return as3.toluatype(n1) + as3.toluatype(n2)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      assertEquals(13, stack[0]);
    }

    public function testBooleanToLuaType():void
    {
      var script:String = ( <![CDATA[
        bt = as3.new("Boolean", true)
        bf = as3.new("Boolean", false)
        return as3.toluatype(bt) == true, as3.toluatype(bf) == false, as3.toluatype(bt), as3.toluatype(bf)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(4, stack.length);
      assertEquals(true, stack[0]);
      assertEquals(true, stack[1]);
      assertEquals(true, stack[2]);
      assertEquals(false, stack[3]);
    }

    // TODO test all Lua to AS3 cast

    public function testAS3Class():void
    {
      var script:String = ( <![CDATA[
        v = as3.class("String")
        return v
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      assertTrue(stack[0] is Class);
    }

    public function testAS3Get():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("Array")
        return as3.get(v, "length")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      assertTrue(stack[0] is int);
      assertEquals(0, stack[0]);
    }


    // TODO test getting every possible type defined in push_as3_to_lua_stack(), 
    // also check type on Lua end

    public function testAS3SetPublicString():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("wrapperSuite.tests::TestWrapperHelper")
        as3.set(v, "string1", "hello")
        return v, as3.get(v, "string1")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(2, stack.length);

      assertTrue(stack[0] is TestWrapperHelper);
      var helper:TestWrapperHelper = stack[0] as TestWrapperHelper;
      assertEquals("hello", helper.string1);

      assertEquals("hello", stack[1]);
    }

    public function testAS3StringGetterSetter():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("wrapperSuite.tests::TestWrapperHelper")
        as3.set(v, "string2", "hello")
        return v, as3.get(v, "string2")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(2, stack.length);

      assertTrue(stack[0] is TestWrapperHelper);
      var helper:TestWrapperHelper = stack[0] as TestWrapperHelper;
      assertEquals("hello", helper.string2);

      assertEquals("hello", stack[1]);
    }

    public function testAS3CallSetNameAge():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("wrapperSuite.tests::TestWrapperHelper")
        as3.call(v, "setNameAge", "Robert", 38)
        return as3.get(v, "nameAge")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(1, stack.length);
      assertEquals("Name: Robert age: 38", stack[0]);
    }

    public function testAS3CallStaticNameAge():void
    {
      var script:String = ( <![CDATA[
        v = as3.class("wrapperSuite.tests::TestWrapperHelper")
        return as3.call(v, "staticNameAge", "Jessie James", 127)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(1, stack.length);
      assertEquals("Name: Jessie James age: 127", stack[0]);
    }

    public function testAS3Yield():void
    {
      var script:String = ( <![CDATA[
        as3.yield()
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(0, stack.length);
    }

    public function testAS3Metatable():void
    {
      var script:String = ( <![CDATA[
        as3.get(io.stdin, "bad")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(1, stack.length);
      assertEquals("[string \"...\"]:2: bad argument #1 to 'get' (LuaAlchemy.as3 expected, got userdata)", stack[0]);
    }

    public function testAS3Type():void
    {
      // TODO: FIXME: Test all available AS3 types (including ones that wouldn't work)
      var script:String = ( <![CDATA[
        ba = as3.new("flash.utils::ByteArray")
        s = as3.new("String")
        return as3.type(ba), as3.type(s)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(2, stack.length);
      assertEquals("flash.utils::ByteArray", stack[0]);
      assertEquals("String", stack[1]);
    }

    public function testAS3TypeInvalid():void
    {
      var script:String = ( <![CDATA[
        return as3.type(5)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      // TODO: This should not crash, but should return nil!
      assertEquals("[string \"...\"]:2: bad argument #1 to 'type' (LuaAlchemy.as3 expected, got number)", stack[0]);
    }

    public function testAS3TypeInvalidUserdata():void
    {
      var script:String = ( <![CDATA[
        return as3.type(newproxy())
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      // TODO: This should not crash, but should return nil!
      assertEquals("[string \"...\"]:2: bad argument #1 to 'type' (LuaAlchemy.as3 expected, got userdata)", stack[0]);
    }

    public function testAS3TypeInvalidUserdataMt():void
    {
      // Have to use debug library since common setmetatable works on tables only
      var script:String = ( <![CDATA[
        local value = newproxy()
        debug.setmetatable(value, {})
        return as3.type(value)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      // TODO: This should not crash, but should return nil!
      assertEquals("[string \"...\"]:4: bad argument #1 to 'type' (LuaAlchemy.as3 expected, got userdata)", stack[0]);
    }

    public function testAS3NamespaceCall():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("wrapperSuite.tests::TestWrapperHelper")
        return as3.namespacecall("flash.utils", "getQualifiedClassName", v)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertEquals(1, stack.length);
      assertEquals("wrapperSuite.tests::TestWrapperHelper", stack[0]);
    }

    public function testAS3SetGlobal():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      lua_wrapper.setGlobal(luaState, myHelper, "testHelper");

      var script:String = ( <![CDATA[
        as3.call(testHelper, "setNameAge", "Bubba Joe Bob Brain", 13)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(0, stack.length);
      assertEquals("Name: Bubba Joe Bob Brain age: 13", myHelper.nameAge);
    }

    public function testLuaAddEventListener():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      lua_wrapper.setGlobal(luaState, myHelper, "testHelper");

      var script:String = ( <![CDATA[
       as3.call(testHelper,
							  "addEventListener",
								"TestWrapperHelperEvent",
								function () as3.call(testHelper, "setNameAge", "Timmy", 99) end)
      ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      myHelper.sendEvent();

      assertEquals(0, stack.length);

      assertEquals("Name: Timmy age: 99", myHelper.nameAge);
    }

    public function testCallLuaFunctionWithParameters():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      lua_wrapper.setGlobal(luaState, myHelper, "testHelper");

      var script:String = ( <![CDATA[
       return function (name, age) as3.call(testHelper, "setNameAge", name, age) end
      ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(1, stack.length);
      assertTrue(stack[0] is Function);

      var func:Function = stack[0] as Function;
      func("Neo", 40);

      assertEquals("Name: Neo age: 40", myHelper.nameAge);
    }

/*
    // TODO: as3.stage() currently returns AS3 void. Fix this
    public function testAS3Stage():void
    {
      var script:String = ( <![CDATA[
        return as3.stage()
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(1, stack.length);
      assertTrue(stack[0] is Stage);
    }
*/    

    /* TODO: Move type conversion tests to a separate suite */

    public function testAS3StringEmpty():void
    {
      var script:String = ( <![CDATA[
        return ""
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals("", stack[0]);
    }

    public function testAS3StringCommon():void
    {
      var script:String = ( <![CDATA[
        return "Lua Alchemy"
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals("Lua Alchemy", stack[0]);
    }

/*
    // TODO: We should try to handle embedded zeroes somehow!
    public function testAS3StringEmbeddedZero():void
    {
      var script:String = ( <![CDATA[
        return "Embedded\0Zero"
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals("Embedded\0Zero", stack[0]);
    }
*/

    public function testAS3True():void
    {
      var script:String = ( <![CDATA[
        return true
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals(true, stack[0]);
    }

    public function testAS3False():void
    {
      var script:String = ( <![CDATA[
        return false
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals(false, stack[0]);
    }

    public function testAS3NumberInteger():void
    {
      var script:String = ( <![CDATA[
        return 42
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals(42, stack[0]);
    }

    public function testAS3NumberPI():void
    {
      var script:String = ( <![CDATA[
        return math.pi
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals(Math.PI, stack[0]);
    }

    public function testAS3NumberPosInf():void
    {
      var script:String = ( <![CDATA[
        return 1/0
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals(1/0, stack[0]);
    }

    public function testAS3NumberNegInf():void
    {
      var script:String = ( <![CDATA[
        return -1/0
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(1, stack.length);
      assertEquals(-1/0, stack[0]);
    }

    public function testAS3NumberNaN():void
    {
      var script:String = ( <![CDATA[
        return 0/0
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(1, stack.length);
      assertTrue(isNaN(stack[0])); // Note NaN != NaN
    }

    public function testAS3Nil():void
    {
      var script:String = ( <![CDATA[
        return nil
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals(null, stack[0]);
    }

/*
    // TODO: This should work!
    public function testAS3UserdataForeign():void
    {
      var script:String = ( <![CDATA[
        return newproxy()
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertEquals(1, stack.length);
      assertEquals("userdata", stack[0]); // TODO: Should return black-box object, not string.
    }
*/

    public function testAS3UserdataAS3():void
    {
      // TODO: Test as much as possible of AS3 types
      var script:String = ( <![CDATA[
        return as3.new("Number")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals(0, stack[0]);
    }

    public function testAS3Table():void
    {
      var script:String = ( <![CDATA[
        return {1}
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals("table", stack[0]); // TODO: Should return black-box object, not string.
    }

    public function testAS3Function():void
    {
      var script:String = ( <![CDATA[
        return function() end
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals("function", stack[0]); // TODO: Should return black-box object, not string.
    }

    public function testAS3Thread():void
    {
      var script:String = ( <![CDATA[
        return coroutine.create(function() end)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
        
      assertEquals(1, stack.length);
      assertEquals("thread", stack[0]); // TODO: Should return black-box object, not string.
    }

/*
    public function testAS3Assign():void
    {
    }
*/
  }
}
