package wrapperSuite.tests
{
  import flash.utils.ByteArray;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestLuaAlchemyInterface extends CommonLuaAlchemyTestCase
  {
    public function testInit():void
    {
      var scriptInit:String = ( <![CDATA[
        iTest = 5 -- intentionally a global so available to next script
        ]]> ).toString();
      var scriptAdd:String = ( <![CDATA[
        return iTest + 5
        ]]> ).toString();

      myLuaAlchemy.doString(scriptInit);
      doString(scriptAdd, [true, 10]);

      myLuaAlchemy.init();
      doString(scriptAdd, [false], false);
    }

    public function testCloseAndAutoInit():void
    {
      var scriptInit:String = ( <![CDATA[
        iTest = 5 -- intentionally a global so available to next script
        ]]> ).toString();
      var scriptAdd:String = ( <![CDATA[
        return iTest + 5
        ]]> ).toString();

      myLuaAlchemy.doString(scriptInit);
      doString(scriptAdd, [true, 10]);

      myLuaAlchemy.close();
      doString(scriptAdd, [false], false);
    }

    public function testDoString():void
    {
      var script:String = ( <![CDATA[
        return "Test doString"
        ]]> ).toString();

      doString(script, [true, "Test doString"])
    }

    public function testDoFile():void
    {
      var script:String = ( <![CDATA[
        return 42
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);

      myLuaAlchemy.supplyFile("myFileDoFileNoError.lua", luaAsset);
      var stack:Array = myLuaAlchemy.doFile("myFileDoFileNoError.lua");

      checkLuaResult([true, 42], stack);
    }

    public function testDoStringAsync():void
    {
      var script:String = ( <![CDATA[
        return "Test doStringAsync"
        ]]> ).toString();

      doStringAsync(100, script, [true, "Test doStringAsync"])
    }

    public function testDoFileAsync():void
    {
      var script:String = ( <![CDATA[
        return 42
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);

      myLuaAlchemy.supplyFile("myFileDoFileNoError.lua", luaAsset);

      doFileAsync(100, "myFileDoFileNoError.lua", [true, 42]);
    }

    public function testSetGlobal():void
    {
      myLuaAlchemy.setGlobal("hello", "Hello There");

      var script:String = ( <![CDATA[
        return hello, as3.type(hello), type(hello)
        ]]> ).toString();

      doString(script, [true, "Hello There", "String", "userdata"])
    }

    public function testSetGlobalLuaValue():void
    {
      myLuaAlchemy.setGlobalLuaValue("hello", "Hello There");

      var script:String = ( <![CDATA[
        return hello, as3.type(hello), type(hello)
        ]]> ).toString();

      doString(script, [true, "Hello There", null, "string"])
    }

    public function testSugarNotLoaded():void
    {
      var script:String = ( <![CDATA[
        assert(as3.class == nil)
      ]]> ).toString();

      doString(script, [true])
    }

    public function testCallGlobalNoGlobal():void
    {
      var script:String = ( <![CDATA[
        local my_global = 42 -- not a global
      ]]> ).toString();
      doString(script, [ true ]);

      var stack:Array = myLuaAlchemy.callGlobal("my_global");
      checkLuaResult([false, "attempt to call a nil value\nstack traceback:"], stack);
    }

    public function testCallGlobalNotAFunction():void
    {
      var script:String = ( <![CDATA[
        my_global = 42
      ]]> ).toString();
      doString(script, [ true ]);

      var stack:Array = myLuaAlchemy.callGlobal("my_global");
      checkLuaResult([false, "attempt to call a number value\nstack traceback:"], stack);
    }

    public function testCallGlobalFunctionFails():void
    {
      var script:String = ( <![CDATA[
        my_global = function()
          error("expected error")
        end
      ]]> ).toString();
      doString(script, [ true ]);

      var stack:Array = myLuaAlchemy.callGlobal("my_global");
      checkLuaResult([false, "luaDoString:3: expected error\nstack traceback:\n\t[C]: in function 'error'\n\tluaDoString:3: in function <luaDoString:2>"], stack);
    }

    public function testCallGlobalNoArgsNoReturnValue():void
    {
      var script:String = ( <![CDATA[
        my_global = function(...)
          assert(select("#", ...) == 0)
        end
      ]]> ).toString();
      doString(script, [ true ]);

      var stack:Array = myLuaAlchemy.callGlobal("my_global");
      checkLuaResult([ true ], stack);
    }

    public function testCallGlobalSmoke():void
    {
      var script:String = ( <![CDATA[
        my_global = function(...)
          assert(select("#", ...) == 5, "bad number of args")
          assert(select(1, ...) == nil, "expected nil")
          assert(select(2, ...) == 42, "expected number")
          assert(select(3, ...) == "forty two", "expected string")
          assert(
              as3.type(select(4, ...)) == "Array",
              "expected array"
            ) -- TODO: Check better
          assert(select(5, ...) == nil, "expected nil")
          return ...
        end
      ]]> ).toString();
      doString(script, [ true ]);

      // Note that full type conversion test is done in a separate suite.
      // Now we're just smoke-testing that all is OK.
      var stack:Array = myLuaAlchemy.callGlobal(
          "my_global",
          null,
          42,
          "forty two",
          [ true ],
          undefined
        );
      checkLuaResult(
          [
            true,
            null,
            42,
            "forty two",
            [ true ],
            undefined
          ],
          stack
        );
    }

    public function testCallGlobalMTSmoke():void
    {
      var script:String = ( <![CDATA[
        local mt =
        {
          __call = function(t, ...)
            -- Note that this argument is passed implicitly by Lua
            assert(t == my_global, "bad t")

            assert(select("#", ...) == 5, "bad number of args")
            assert(select(1, ...) == nil, "expected nil")
            assert(select(2, ...) == 42, "expected number")
            assert(select(3, ...) == "forty two", "expected string")
            assert(
                as3.type(select(4, ...)) == "Array",
                "expected array"
              ) -- TODO: Check better
            assert(select(5, ...) == nil, "expected nil")
            return ...
          end;
        }
        my_global = setmetatable({ }, mt)
      ]]> ).toString();
      doString(script, [ true ]);

      // Note that full type conversion test is done in a separate suite.
      // Now we're just smoke-testing that all is OK.
      var stack:Array = myLuaAlchemy.callGlobal(
          "my_global",
          null,
          42,
          "forty two",
          [ true ],
          undefined
        );
      checkLuaResult(
          [
            true,
            null,
            42,
            "forty two",
            [ true ],
            undefined
          ],
          stack
        );
    }

    /*
    * If you do anything in Lua after you invoked doStringAsync,
    * it crashes in luaV_execute.
    *
    * See http://code.google.com/p/lua-alchemy/issues/detail?id=154 for details.
    *
    * TODO: Fix that.
    * TODO: While not fixed, test also that callbacks also are protected
    *       from accidentally calling do*Async() from Lua code.
    * TODO: Fix and uncomment those assert('unreachable 3'),
    *       they should not crash.
    * TODO: In fact, whole set of tests is broken and messes up
    *       with Alchemy, breaking other tests. Uncomment them and fix that.
    */

    /*
    public function testDoStringAsyncNotCallableFromSameLuaState():void
    {
      myLuaAlchemy.setGlobal("_ALCHEMY", myLuaAlchemy);

      var script:String = ( <![CDATA[
        as3.call(
            _ALCHEMY,
            "doStringAsync",
            [[
              assert("unreachable 1")
            ]],
            function(stack)
              assert("unreachable 2")
            end
          )

--        assert("unreachable 3")

      ]]> ).toString();

      doString(
          script,
          [ false, "can't call doStringAsync from Lua" ]
        );
    }

    public function testDoStringAsyncNotCallableFromOtherLuaState():void
    {
      var script:String = ( <![CDATA[
        local lua = as3.new("luaAlchemy::LuaAlchemy")
        as3.call(
            lua,
            "doStringAsync",
            [[
              assert("unreachable 1")
            ]],
            function(stack)
              assert("unreachable 2")
            end
          )

--        assert("unreachable 3")

      ]]> ).toString();

      doString(
          script,
          [ false, "can't call doStringAsync from Lua" ]
        );
    }

    public function testDoFileAsyncNotCallableFromSameLuaState():void
    {
      myLuaAlchemy.setGlobal("_ALCHEMY", myLuaAlchemy);

      var script:String = ( <![CDATA[
        local bytes = as3.new("flash.utils::ByteArray")
        as3.call(bytes, "writeMultiByte", [[assert("unreachable 1")]], "UTF-8")
        as3.call(_ALCHEMY, "supplyFile", "test://foo.lua", bytes)

        as3.call(
            _ALCHEMY,
            "doFileAsync",
            "test://foo.lua",
            function(stack)
              assert("unreachable 2")
            end
          )

--        assert("unreachable 3")

      ]]> ).toString();

      doString(
          script,
          [ false, "can't call doFileAsync from Lua" ]
        );
    }

    public function testDoFileAsyncNotCallableFromOtherLuaState():void
    {
      var script:String = ( <![CDATA[
        local lua = as3.new("luaAlchemy::LuaAlchemy")
        local bytes = as3.new("flash.utils::ByteArray")
        as3.call(bytes, "writeMultiByte", [[assert("unreachable 1")]], "UTF-8")
        as3.call(lua, "supplyFile", "test://foo.lua", bytes)

        as3.call(
            lua,
            "doFileAsync",
            "test://foo.lua",
            function(stack)
              assert("unreachable 2")
            end
          )

        assert("unreachable 3")

      ]]> ).toString();

      doString(
          script,
          [ false, "can't call doFileAsync from Lua" ]
        );
    }
    */
  }
}
