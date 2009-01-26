package wrapperSuite.tests
{
  import luaAlchemy.lua_wrapper;

  import flash.utils.ByteArray;
  import net.digitalprimates.fluint.tests.TestCase;

  public class TestTypeConversion extends CommonTestCaseWrapper
  {
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

      doString(script, [true]);
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

      doString(script, [true, true, true, true, false]);
    }

        /* TODO: Move type conversion tests to a separate suite */

        public function testAS3StringEmpty():void
        {
          var script:String = ( <![CDATA[
            return ""
            ]]> ).toString();

          doString(script, [true, ""]);
        }

        public function testAS3StringCommon():void
        {
          var script:String = ( <![CDATA[
            return "Lua Alchemy"
            ]]> ).toString();

          doString(script, [true, "Lua Alchemy"]);
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

          doString(script, [true, true]);
        }

        public function testAS3False():void
        {
          var script:String = ( <![CDATA[
            return false
            ]]> ).toString();

          doString(script, [true, false]);
        }

        public function testAS3NumberInteger():void
        {
          var script:String = ( <![CDATA[
            return 42
            ]]> ).toString();

          doString(script, [true, 42]);
        }

        public function testAS3NumberPI():void
        {
          var script:String = ( <![CDATA[
            return math.pi
            ]]> ).toString();

          doString(script, [true, Math.PI]); // Note this is implementation specific. Compare with epsilon.
        }

        public function testAS3NumberPosInf():void
        {
          var script:String = ( <![CDATA[
            return 1/0
            ]]> ).toString();

          doString(script, [true, 1/0]);
        }

        public function testAS3NumberNegInf():void
        {
          var script:String = ( <![CDATA[
            return -1/0
            ]]> ).toString();

          doString(script, [true, -1/0]);
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

          doString(script, [true, null]);
        }

        public function testAS3UserdataForeign():void
        {
          var script:String = ( <![CDATA[
            return newproxy()
            ]]> ).toString();

          doString(script, [true, "userdata"]); // TODO: stack[1] Should return black-box object, not string.
        }

        public function testAS3UserdataAS3():void
        {
          // TODO: Test as much as possible of AS3 types
          var script:String = ( <![CDATA[
            return as3.new("Number")
            ]]> ).toString();

          doString(script, [true, 0]);
        }

        public function testAS3Table():void
        {
          var script:String = ( <![CDATA[
            return {1}
            ]]> ).toString();

          doString(script, [true, "table"]); // TODO: stack[1] Should return black-box object, not string.
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

          doString(script, [true, "thread"]); // TODO: stack[1] Should return black-box object, not string.
        }

        private function passThroughTest(asValIn:*, luaVal:String, asValOut:*):void
        {
          lua_wrapper.setGlobalLuaValue(luaState, "myValue", asValIn);

          var script:String = ( <![CDATA[
            if myValue ~= ]]> ) + luaVal + ( <![CDATA[ then
              as3.trace("BAD VALUE, GOT", myValue, "EXPECTED", ]]> ) + luaVal + ( <![CDATA[)
              error("myValue mismatch")
            end
            return myValue
            ]]> ).toString();

          doString(script, [true, asValOut]);
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
          lua_wrapper.setGlobalLuaValue(luaState, "myValue", 0/0);

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

          doString(script, [true, myHelper]);
        }
  }
}
