package wrapperSuite.tests
{
  import luaAlchemy.lua_wrapper;

  import flash.utils.ByteArray;
  import net.digitalprimates.fluint.tests.TestCase;

  public class TestAS3LuaInterface extends CommonTestCase
  {
    public function testAS3NewArray():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("Array")
        return v
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertTrue(stack[0]);
      assertTrue(stack[1] is Array);
      assertEquals(2, stack.length);
    }

    public function testAS3NewByteArray():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("flash.utils::ByteArray")
        return v
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertTrue(stack[0]);
      assertTrue(stack[1] is ByteArray);
      assertEquals(2, stack.length);
    }

    public function testAS3Release():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("flash.utils::ByteArray")
        as3.release(v)
        return v
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertTrue(stack[0]);
      assertNull(stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3ToLuaTypeNumber():void
    {
      var script:String = ( <![CDATA[
        n1 = as3.new("int", 7)
        n2 = as3.new("Number", 6)
        return as3.tolua(n1) + as3.tolua(n2)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertTrue(stack[0]);
      assertEquals(13, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3Class():void
    {
      var script:String = ( <![CDATA[
        v = as3.class("String")
        return v
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertTrue(stack[0]);
      assertTrue(stack[1] is Class);

      assertEquals(2, stack.length);
    }

    public function testAS3Get():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("Array")
        return as3.get(v, "length")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertTrue(stack[0]);
      assertTrue(stack[1] is int);
      assertEquals(0, stack[1]);

      assertEquals(2, stack.length);
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

      assertTrue(stack[0]);

      assertTrue(stack[1] is TestWrapperHelper);
      var helper:TestWrapperHelper = stack[1] as TestWrapperHelper;
      assertEquals("hello", helper.string1);

      assertEquals("hello", stack[2]);

      assertEquals(3, stack.length);
    }

    public function testAS3StringGetterSetter():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("wrapperSuite.tests::TestWrapperHelper")
        as3.set(v, "string2", "hello")
        return v, as3.get(v, "string2")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);

      assertTrue(stack[1] is TestWrapperHelper);
      var helper:TestWrapperHelper = stack[1] as TestWrapperHelper;
      assertEquals("hello", helper.string2);

      assertEquals("hello", stack[2]);

      assertEquals(3, stack.length);
    }

    public function testAS3CallSetNameAge():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("wrapperSuite.tests::TestWrapperHelper")
        as3.call(v, "setNameAge", "Robert", 38)
        return as3.get(v, "nameAge")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals("Name: Robert age: 38", stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3CallStaticNameAge():void
    {
      var script:String = ( <![CDATA[
        v = as3.class("wrapperSuite.tests::TestWrapperHelper")
        return as3.call(v, "staticNameAge", "Jessie James", 127)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals("Name: Jessie James age: 127", stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3Yield():void
    {
      var script:String = ( <![CDATA[
        as3.yield()
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(1, stack.length);
    }

    public function testAS3Trace():void
    {
      var script:String = ( <![CDATA[
        as3.trace("trace test", 1, 2, "boo", {}, function() end)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      trace(stack);
      assertTrue(stack[0]);
      assertEquals(1, stack.length);
    }

    public function testAS3Metatable():void
    {
      var script:String = ( <![CDATA[
        as3.get(io.stdin, "bad")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertFalse(stack[0]);
      assertEquals("luaDoString:2: bad argument #1 to 'get' (LuaAlchemy.as3 expected, got userdata)\nstack traceback:\n\t[C]: in function 'get'\n\tluaDoString:2: in main chunk", stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3NamespaceCall():void
    {
      var script:String = ( <![CDATA[
        v = as3.new("wrapperSuite.tests::TestWrapperHelper")
        return as3.namespacecall("flash.utils", "getQualifiedClassName", v)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertTrue(stack[0]);
      assertEquals("wrapperSuite.tests::TestWrapperHelper", stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3SetGlobal():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      lua_wrapper.setGlobal(luaState, "testHelper", myHelper);

      var script:String = ( <![CDATA[
        as3.call(testHelper, "setNameAge", "Bubba Joe Bob Brain", 13)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals("Name: Bubba Joe Bob Brain age: 13", myHelper.nameAge);
      assertEquals(1, stack.length);
    }

    /*
        // TODO: as3.stage() currently returns AS3 void. Fix this
        public function testAS3Stage():void
        {
          var script:String = ( <![CDATA[
            return as3.stage()
            ]]> ).toString();
          var stack:Array = lua_wrapper.luaDoString(luaState, script);

          assertTrue(stack[0] is Stage);
          assertEquals(1, stack.length);
        }
    */
      public function testAS3Type():void
      {
        // TODO: FIXME: Test all available AS3 types (including ones that wouldn't work)
        var script:String = ( <![CDATA[
          local ba = as3.new("flash.utils::ByteArray")
          local s = as3.new("String")
          return as3.type(ba), as3.type(s)
          ]]> ).toString();
        var stack:Array = lua_wrapper.luaDoString(luaState, script);
        assertTrue(stack[0]);
        assertEquals("flash.utils::ByteArray", stack[1]);
        assertEquals("String", stack[2]);
        assertEquals(3, stack.length);
      }

      public function testAS3TypeNoArgs():void
      {
        var script:String = ( <![CDATA[
          return as3.type()
          ]]> ).toString();
        var stack:Array = lua_wrapper.luaDoString(luaState, script);
        assertFalse(stack[0]);
        // TODO: This should not crash, but should return nil!
        assertEquals("luaDoString:2: bad argument #1 to 'type' (value expected)\nstack traceback:\n\t[C]: in function 'type'\n\tluaDoString:2: in main chunk", stack[1]);
        assertEquals(2, stack.length);
      }

      public function testAS3TypeInvalid():void
      {
        var script:String = ( <![CDATA[
          assert(as3.type(5) == nil)
          ]]> ).toString();
        var stack:Array = lua_wrapper.luaDoString(luaState, script);
        assertTrue(stack[0]);
        assertEquals(1, stack.length);
      }

      public function testAS3TypeInvalidUserdata():void
      {
        var script:String = ( <![CDATA[
          assert(as3.type(newproxy()) == nil)
          ]]> ).toString();
        var stack:Array = lua_wrapper.luaDoString(luaState, script);
        assertTrue(stack[0]);
        assertEquals(1, stack.length);
      }

      public function testAS3TypeInvalidUserdataMt():void
      {
        // Have to use debug library since common setmetatable works on tables only
        var script:String = ( <![CDATA[
          local value = newproxy()
          debug.setmetatable(value, {})
          assert(as3.type(value) == nil)
          ]]> ).toString();
        var stack:Array = lua_wrapper.luaDoString(luaState, script);
        assertTrue(stack[0]);
        assertEquals(1, stack.length);
      }

      /*
          TODO public function testAS3Assign():void
          {
          }
      */


  }
}
