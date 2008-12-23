package wrapperSuite.tests
{
  import flash.utils.ByteArray;

  import luaAlchemy.lua_wrapper;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestWrapper extends CommonTestCase
  {
    public function TestWrapper()
    {
      super();
    }

    private function checkDoStringResult(expected:Array, actual:Array):void
    {
      assertEquals("stack length", expected.length, actual.length);
      for (var i:int = 0; i < expected.length; ++i)
      {
        if (i == 0)
        {
          assertEquals("success code", expected[i], actual[i]);
        }
        else
        {
          assertEquals("return value #" + i, expected[i], actual[i]);
        }
      }
    }

    // TODO: Reuse!
    private function doString(script:String, expected:Array):void
    {
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      checkDoStringResult(expected, stack);
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
      doString(script, [ true, 6 ]);
    }

    public function testAS3ToLuaTolerantToNativeTypesAndIsVariadic():void
    {
      var script:String = ( <![CDATA[
        local check = function(msg, a, e)
          if type(a) ~= type(e) then
            error(msg ..": unexpected type: got "..type(a).." expected "..type(e))
          end

          if a ~= e then
            error(msg ..": unexpected value: got "..tostring(a).." expected "..tostring(e))
          end
        end
        local a, b, c, d = as3.tolua(
            1,
            "Lua Alchemy",
            as3.new("Number", 42),
            as3.new("flash.utils::ByteArray")
          )
        check("a", a, 1)
        check("b", b, "Lua Alchemy")
        check("c", c, 42)

        if type(d) ~= "userdata" then
          error("d: unexpected type: got "..type(a).." expected userdata")
        end

        if as3.type(d) ~= "flash.utils::ByteArray" then
          error("d: unexpected as3.type: got "..as3.type(a).." expected flash.utils::ByteArray")
        end

        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertTrue(stack[0]);
      assertEquals(1, stack.length);
    }

    public function testBooleanToLuaType():void
    {
      var script:String = ( <![CDATA[
        bt = as3.new("Boolean", true)
        bf = as3.new("Boolean", false)
        return
          as3.tolua(bt) == true,
          as3.tolua(bf) == false,
          as3.tolua(bt),
          as3.tolua(bf)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(true, stack[1]);
      assertEquals(true, stack[2]);
      assertEquals(true, stack[3]);
      assertEquals(false, stack[4]);
      assertEquals(5, stack.length);
    }

    // TODO test all Lua to AS3 cast

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

    public function testLuaAddEventListener():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      lua_wrapper.setGlobal(luaState, "testHelper", myHelper);

      var script:String = ( <![CDATA[
       as3.call(testHelper,
                "addEventListener",
                "TestWrapperHelperEvent",
                function () as3.call(testHelper, "setNameAge", "Timmy", 99) end)
      ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      myHelper.sendEvent();

      assertTrue(stack[0]);
      assertEquals(1, stack.length);

      assertEquals("Name: Timmy age: 99", myHelper.nameAge);
    }

    public function testCallLuaNoop():void
    {
      var script:String = ( <![CDATA[
      ]]> ).toString();

      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      trace(stack.toString());
      assertTrue(stack[0]);
      assertEquals(1, stack.length);
    }

    public function testSyntaxError():void
    {
      var script:String = ( <![CDATA[
        bad code here
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertFalse(stack[0]);
      assertEquals("luaDoString:2: '=' expected near 'code'", stack[1]);
      assertEquals(2, stack.length);
    }

    public function testRuntimeErrorString():void
    {
      var script:String = ( <![CDATA[
        error("my runtime error")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertFalse(stack[0]);
      assertEquals("luaDoString:2: my runtime error\nstack traceback:\n\t[C]: in function 'error'\n\tluaDoString:2: in main chunk", stack[1]);
      assertEquals(2, stack.length);
    }

    public function testRuntimeErrorNonstring():void
    {
      var script:String = ( <![CDATA[
        error({})
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertFalse(stack[0]);
      assertEquals("table", stack[1]); // TODO: Should be a black-boxed object
      assertEquals(2, stack.length);
    }

    public function testCallLuaFunctionGetNoop():void
    {
      var script:String = ( <![CDATA[
       return function() end
      ]]> ).toString();

      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      trace(stack.toString());
      assertTrue(stack[0]);
      assertTrue(stack[1] is Function);
      assertEquals(2, stack.length);
    }

    public function testCallLuaFunctionCallNoop():void
    {
      var script:String = ( <![CDATA[
       return function() end
      ]]> ).toString();

      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      trace(stack.toString());

      assertTrue(stack[0]);
      assertTrue(stack[1] is Function);
      assertEquals(2, stack.length);

      var func:Function = stack[1] as Function;

      var ret:* = func();
      assertEquals(null, ret);
    }

    public function testLuaCallbackCleanupWithListener():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      myHelper.count = 0;

      var script:String = ( <![CDATA[
       as3.call(testHelper,
                "addEventListener",
                "TestWrapperIncrementEvent",
                function () as3.set(testHelper, "count", as3.get(testHelper, "count") + 1) end)
      ]]> ).toString();

      var stack:Array;
      var expected:int;
      for (expected = 1; expected <= 10; expected++)
      {
        lua_wrapper.luaClose(luaState);
        luaState = lua_wrapper.luaInitilizeState();
        lua_wrapper.setGlobal(luaState, "testHelper", myHelper);

        stack = lua_wrapper.luaDoString(luaState, script);

        myHelper.sendIncrementEvent();

        assertEquals(1, stack.length);
        assertTrue(stack[0]);
        assertEquals(expected, myHelper.count);
      }
    }

		// TODO test garbage collection cleanup (like the movebox demo)

    public function testCallLuaFunctionWithParametersNilReturn():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      lua_wrapper.setGlobal(luaState, "testHelper", myHelper);

      var script:String = ( <![CDATA[
       return function (name, age) as3.call(testHelper, "setNameAge", name, age) end
      ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertTrue(stack[1] is Function);
      assertEquals(2, stack.length);

      var func:Function = stack[1] as Function;
      var ret:* = func("Neo", 40);
      assertEquals(null, ret);

      assertEquals("Name: Neo age: 40", myHelper.nameAge);
    }

    public function testCallLuaFunctionWithSingleReturn():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      lua_wrapper.setGlobal(luaState, "testHelper", myHelper);

      var script:String = ( <![CDATA[
       return function ()
            return 1 + 12
        end
      ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertTrue(stack[1] is Function);
      assertEquals(2, stack.length);

      var func:Function = stack[1] as Function;
      var ret:* = func();
      assertTrue(ret is Number);
      assertEquals(13, ret);
    }

    public function testCallLuaFunctionWithMultiReturn():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      lua_wrapper.setGlobal(luaState, "testHelper", myHelper);

      var script:String = ( <![CDATA[
        return function ()
          return 1 + 12, "hello there"
        end
      ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertTrue(stack[1] is Function);
      assertEquals(2, stack.length);

      var func:Function = stack[1] as Function;
      var ret:* = func();

      assertTrue(ret is Array);
      assertEquals(2, ret.length);
      assertEquals(13, ret[0]);
      assertEquals("hello there", ret[1]);
    }

    /* TODO: Move type conversion tests to a separate suite */

    public function testAS3StringEmpty():void
    {
      var script:String = ( <![CDATA[
        return ""
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals("", stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3StringCommon():void
    {
      var script:String = ( <![CDATA[
        return "Lua Alchemy"
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals("Lua Alchemy", stack[1]);
      assertEquals(2, stack.length);
    }

/*
    // TODO: Looks like there is a bug in Alchemy .5a AS3_StringN().
    public function testAS3StringEmbeddedZeroAS3():void
    {
      var script:String = ( <![CDATA[
        return as3.new("String", "Embedded\0Zero")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      // Note this does crazy things with test suite error output
      assertEquals("Embedded\u0000Zero", stack[0]);
      assertEquals(1, stack.length);
    }
*/

    public function testAS3True():void
    {
      var script:String = ( <![CDATA[
        return true
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(true, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3False():void
    {
      var script:String = ( <![CDATA[
        return false
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(false, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3NumberInteger():void
    {
      var script:String = ( <![CDATA[
        return 42
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(42, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3NumberPI():void
    {
      var script:String = ( <![CDATA[
        return math.pi
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(Math.PI, stack[1]); // Note this is implementation specific. Compare with epsilon.
      assertEquals(2, stack.length);
    }

    public function testAS3NumberPosInf():void
    {
      var script:String = ( <![CDATA[
        return 1/0
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(1/0, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3NumberNegInf():void
    {
      var script:String = ( <![CDATA[
        return -1/0
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(-1/0, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3NumberNaN():void
    {
      var script:String = ( <![CDATA[
        return 0/0
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertTrue(isNaN(stack[1])); // Note NaN != NaN
      assertEquals(2, stack.length);
    }

    public function testAS3Nil():void
    {
      var script:String = ( <![CDATA[
        return nil
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(null, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3UserdataForeign():void
    {
      var script:String = ( <![CDATA[
        return newproxy()
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals("userdata", stack[1]); // TODO: Should return black-box object, not string.
      assertEquals(2, stack.length);
    }

    public function testAS3UserdataAS3():void
    {
      // TODO: Test as much as possible of AS3 types
      var script:String = ( <![CDATA[
        return as3.new("Number")
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(0, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testAS3Table():void
    {
      var script:String = ( <![CDATA[
        return {1}
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals("table", stack[1]); // TODO: Should return black-box object, not string.
      assertEquals(2, stack.length);
    }

    public function testAS3Function():void
    {
      var script:String = ( <![CDATA[
        return function() end
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertTrue(stack[1] is Function);
      assertEquals(2, stack.length);
    }

    public function testAS3Thread():void
    {
      var script:String = ( <![CDATA[
        return coroutine.create(function() end)
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals("thread", stack[1]); // TODO: Should return black-box object, not string.
      assertEquals(2, stack.length);
    }

    private function passThroughTest(asValIn:*, luaVal:String, asValOut:*):void
    {
      lua_wrapper.setGlobal(luaState, "myValue", asValIn);

      var script:String = ( <![CDATA[
        if myValue ~= ]]> ) + luaVal + ( <![CDATA[ then
          as3.trace("BAD VALUE, GOT", myValue, "EXPECTED", ]]> ) + luaVal + ( <![CDATA[)
          error("myValue mismatch")
        end
        return myValue
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(asValOut, stack[1]);
      assertEquals(2, stack.length);
    }

    // TODO: Test all supported AS3 types in that manner!
    //       Note this does not replace separate testing of AS3 value
    //       creation in the Lua.
    public function testAS3PassThroughStringEmpty():void
    {
      passThroughTest("", <![CDATA[""]]>, "");
    }

    public function testAS3PassThroughStringCommon():void
    {
      passThroughTest("Lua Alchemy", <![CDATA["Lua Alchemy"]]>, "Lua Alchemy");
    }

/*
    // TODO: Looks like there is a bug in Alchemy .5a AS3_StringN().
    public function testAS3PassThroughStringEmbeddedZero():void
    {
      passThroughTest("Embedded\u0000Zero", <![CDATA["Embedded\0Zero"]]>, "Embedded\u0000Zero");
    }
*/

    public function testAS3PassThroughNull():void
    {
      passThroughTest(null, <![CDATA[nil]]>, null);
    }

    public function testAS3PassThroughUndefined():void
    {
      passThroughTest(undefined, <![CDATA[nil]]>, null);
    }

    public function testAS3PassThroughNumberIntegral():void
    {
      passThroughTest(42, <![CDATA[42]]>, 42);
    }

    public function testAS3PassThroughNumberPI():void
    {
      passThroughTest(Math.PI, <![CDATA[math.pi]]>, Math.PI);
    }

    public function testAS3PassThroughNumberPosInf():void
    {
      passThroughTest(1/0, <![CDATA[1/0]]>, 1/0);
    }

    public function testAS3PassThroughNumberNegInf():void
    {
      passThroughTest(-1/0, <![CDATA[-1/0]]>, -1/0);
    }

    public function testAS3PassThroughNumberNaN():void
    {
      lua_wrapper.setGlobal(luaState, "myValue", 0/0);

      var script:String = ( <![CDATA[
        assert(type(myValue) == "number")
        assert(myValue ~= myValue)
        return myValue
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertTrue(isNaN(stack[1]));
      assertEquals(2, stack.length);
    }

    public function testAS3PassThroughBooleanTrue():void
    {
      passThroughTest(true, <![CDATA[true]]>, true);
    }

    public function testAS3PassThroughBooleanFalse():void
    {
      passThroughTest(false, <![CDATA[false]]>, false);
    }

    public function testAS3PassThroughObject():void
    {
      var myHelper:TestWrapperHelper = new TestWrapperHelper();
      lua_wrapper.setGlobal(luaState, "myValue", myHelper);

      var script:String = ( <![CDATA[
        if as3.type(myValue) ~= "wrapperSuite.tests::TestWrapperHelper" then
          error("Bad as3.type of myValue: " .. as3.type(myValue))
        end
        return myValue
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      assertTrue(stack[0]);
      assertEquals(myHelper, stack[1]);
      assertEquals(2, stack.length);
    }

/*
    public function testAS3Assign():void
    {
    }
*/

    public function testCreateCallbackInLua():void
    {
      var script:String = ( <![CDATA[
        as3.new("Function", function() end) -- TODO: Does this make sense?
        ]]> ).toString();

      var stack:Array = lua_wrapper.luaDoString(luaState, script);
      assertTrue(stack[0]);
      assertEquals(1, stack.length);
    }

    public function testCreateAndCallObject():void
    {
      var script:String = ( <![CDATA[
        local create_as_object = function()
           local obj = as3.new("Object")
           as3.set(
               obj,
               "addThirteen",
               function(n)
                 return n + 13
               end
             )
           return obj
        end
        local as_object = create_as_object()
        local result = as3.call(as_object, "addThirteen", 5)
        result = result + 2
        return result
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      trace(stack);

      assertTrue(stack[0]);
      assertEquals(20, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testCreateAndCallObjectErrorNonstring():void
    {
      var script:String = ( <![CDATA[
        local create_as_object = function()
           local obj = as3.new("Object")
           as3.set(
               obj,
               "error",
               function(n)
                 error({})
               end
             )
           return obj
        end
        local as_object = create_as_object()
        as3.call(as_object, "error")
        return "error is ignored"
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      trace(stack);

      assertTrue(stack[0]);
      assertEquals("error is ignored", stack[1]);
      assertEquals(2, stack.length);
    }

    public function testCreateAndCallObjectErrorString():void
    {
      var script:String = ( <![CDATA[
        local create_as_object = function()
           local obj = as3.new("Object")
           as3.set(
               obj,
               "error",
               function(n)
                 as3.trace("about to trigger error")
                 error("Boo!")
               end
             )
           return obj
        end
        local as_object = create_as_object()
        as3.trace("about to call method")
        as3.call(as_object, "error")
        return "error is ignored"
        ]]> ).toString();
      var stack:Array = lua_wrapper.luaDoString(luaState, script);

      trace(stack);

      assertTrue(stack[0]);
      assertEquals("error is ignored", stack[1]);
      assertEquals(2, stack.length);
    }
  }
}
