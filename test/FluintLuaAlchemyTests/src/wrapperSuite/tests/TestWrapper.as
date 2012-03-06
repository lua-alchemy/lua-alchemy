package wrapperSuite.tests
{
  import flash.utils.ByteArray;

  import luaAlchemy.lua_wrapper;
  import cmodule.lua_wrapper.CLibInit;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestWrapper extends CommonTestCaseWrapper
  {
    public function testCreateCloseContext():void
    {
      var luaState:uint = lua_wrapper.luaInitializeState();
      assertTrue(luaState != 0);
      lua_wrapper.luaClose(luaState);
    }

    public function testDoScriptAdd():void
    {
      var script:String = ( <![CDATA[
        assert(as3.is_async == false)
        return 1+5
        ]]> ).toString();
      doString(script, [ true, 6 ]);
    }

    public function testCallLuaNoop():void
    {
      var script:String = ( <![CDATA[
      ]]> ).toString();

      doString(script, [true]);
    }

    public function testSyntaxError():void
    {
      var script:String = ( <![CDATA[
        bad code here
        ]]> ).toString();

      doString(script, [false, "luaDoString:2: '=' expected near 'code'"]);
    }

    public function testRuntimeErrorString():void
    {
      var script:String = ( <![CDATA[
        error("my runtime error")
        ]]> ).toString();

      doString(script, [false, "luaDoString:2: my runtime error\nstack traceback:\n\t[C]: in function 'error'\n\tluaDoString:2: in main chunk"]);
    }

    public function testRuntimeErrorNonstring():void
    {
      var script:String = ( <![CDATA[
        error({})
        ]]> ).toString();

      // TODO: stack[1] Should be a black-boxed object
      doString(script, [false, "table"]);
    }

    // Note: it seems that you can not override once supplied file in Alchemy

    public function testDoFileNoError():void
    {
      var script:String = ( <![CDATA[
        assert(as3.is_async == false)
        return 42
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);
      const libInitializer:CLibInit = new CLibInit();
      libInitializer.supplyFile("myFileDoFileNoError.lua", luaAsset);
      var stack:Array = lua_wrapper.doFile(luaState, "myFileDoFileNoError.lua");

      checkLuaResult([true, 42], stack);
    }

    public function testDoFileNoFile():void
    {
      var stack:Array = lua_wrapper.doFile(luaState, "no such file");

      checkLuaResult([false, "cannot open no such file: No such file or directory"], stack);
    }

    public function testDoFileSyntaxError():void
    {
      var script:String = ( <![CDATA[
        bad code here
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);
      const libInitializer:CLibInit = new CLibInit();
      libInitializer.supplyFile("myFileSyntaxError.lua", luaAsset);
      var stack:Array = lua_wrapper.doFile(luaState, "myFileSyntaxError.lua");

      checkLuaResult([false, "myFileSyntaxError.lua:2: '=' expected near 'code'"], stack);
    }

    public function testDoFileRuntimeErrorString():void
    {
      var script:String = ( <![CDATA[
        error("my runtime error")
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);
      const libInitializer:CLibInit = new CLibInit();
      libInitializer.supplyFile("myFileRuntimeErrorString.lua", luaAsset);
      var stack:Array = lua_wrapper.doFile(luaState, "myFileRuntimeErrorString.lua");

      checkLuaResult([false, "myFileRuntimeErrorString.lua:2: my runtime error\nstack traceback:\n\t[C]: in function 'error'\n\tmyFileRuntimeErrorString.lua:2: in main chunk"], stack);
    }

    public function testDoFileRuntimeErrorTable():void
    {
      var script:String = ( <![CDATA[
        error({})
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);
      const libInitializer:CLibInit = new CLibInit();
      libInitializer.supplyFile("myFileRuntimeErrorTable.lua", luaAsset);
      var stack:Array = lua_wrapper.doFile(luaState, "myFileRuntimeErrorTable.lua");

      // TODO: stack[1] Should be a black-boxed object
      checkLuaResult([false, "table"], stack);
    }

    public function testReturnMultibyteString():void
    {
      var script:String = ( <![CDATA[
        return "Привет!" -- Hello!
        ]]> ).toString();
      doString(script, [ true, "Привет!" ]);
    }

    ////////////////////////////////////////////////////////////////////////////

    public function testDoScriptAddAsync():void
    {
      var script:String = ( <![CDATA[
        assert(as3.is_async == true)
        return 1+5
        ]]> ).toString();
      doStringAsync(100, script, [ true, 6 ]);
    }

    public function testCallLuaNoopAsync():void
    {
      var script:String = ( <![CDATA[
      ]]> ).toString();

      doStringAsync(100, script, [true]);
    }

    public function testSyntaxErrorAsync():void
    {
      var script:String = ( <![CDATA[
        bad code here
        ]]> ).toString();

      doStringAsync(100, script, [false, "luaDoString:2: '=' expected near 'code'"]);
    }

    public function testRuntimeErrorStringAsync():void
    {
      var script:String = ( <![CDATA[
        error("my runtime error")
        ]]> ).toString();

      doStringAsync(100, script, [false, "luaDoString:2: my runtime error\nstack traceback:\n\t[C]: in function 'error'\n\tluaDoString:2: in main chunk"]);
    }

    public function testRuntimeErrorNonstringAsync():void
    {
      var script:String = ( <![CDATA[
        error({})
        ]]> ).toString();

      // TODO: stack[1] Should be a black-boxed object
      doStringAsync(100, script, [false, "table"]);
    }

    public function testReturnMultibyteStringAsync():void
    {
      var script:String = ( <![CDATA[
        return "Привет!" -- Hello!
        ]]> ).toString();
      doStringAsync(100, script, [ true, "Привет!" ]);
    }

    // Note: it seems that you can not override once supplied file in Alchemy

    public function testDoFileNoErrorAsync():void
    {
      var script:String = ( <![CDATA[
        assert(
            as3.is_async == true, "must be in async mode: " .. tostring(as3.is_async)
          )
        return 42
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);
      const libInitializer:CLibInit = new CLibInit();
      libInitializer.supplyFile("myFileDoFileNoErrorAsync.lua", luaAsset);

      doFileAsync(100, "myFileDoFileNoErrorAsync.lua", [true, 42]);
    }

    public function testDoFileNoFileAsync():void
    {
      var stack:Array = lua_wrapper.doFile(luaState, "no such file");

      doFileAsync(100, "no such file", [false, "cannot open no such file: No such file or directory"]);
    }

    public function testDoFileSyntaxErrorAsync():void
    {
      var script:String = ( <![CDATA[
        bad code here
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);
      const libInitializer:CLibInit = new CLibInit();
      libInitializer.supplyFile("myFileSyntaxErrorAsync.lua", luaAsset);

      doFileAsync(100, "myFileSyntaxErrorAsync.lua", [false, "myFileSyntaxErrorAsync.lua:2: '=' expected near 'code'"]);
    }

    public function testDoFileRuntimeErrorStringAsync():void
    {
      var script:String = ( <![CDATA[
        error("my runtime error")
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);
      const libInitializer:CLibInit = new CLibInit();
      libInitializer.supplyFile("myFileRuntimeErrorStringAsync.lua", luaAsset);
      var stack:Array = lua_wrapper.doFile(luaState, "myFileRuntimeErrorStringAsync.lua");

      doFileAsync(100, "myFileRuntimeErrorStringAsync.lua", [false, "myFileRuntimeErrorStringAsync.lua:2: my runtime error\nstack traceback:\n\t[C]: in function 'error'\n\tmyFileRuntimeErrorStringAsync.lua:2: in main chunk"]);
    }

    public function testDoFileRuntimeErrorTableAsync():void
    {
      var script:String = ( <![CDATA[
        error({})
        ]]> ).toString();
      var luaAsset:ByteArray = new ByteArray();
      luaAsset.writeUTFBytes(script);
      const libInitializer:CLibInit = new CLibInit();
      libInitializer.supplyFile("myFileRuntimeErrorTableAsync.lua", luaAsset);

      // TODO: stack[1] Should be a black-boxed object
      doFileAsync(100, "myFileRuntimeErrorTableAsync.lua", [false, "table"]);
    }

// -----------------------------------------------------------------------------

    public function testCallGlobalNoGlobal():void
    {
      var script:String = ( <![CDATA[
        local my_global = 42 -- not a global
      ]]> ).toString();
      doString(script, [ true ]);

      var stack:Array = lua_wrapper.callGlobal(
          luaState, "my_global", [ ]
        );
      checkLuaResult([false, "attempt to call a nil value\nstack traceback:"], stack);
    }

    public function testCallGlobalNotAFunction():void
    {
      var script:String = ( <![CDATA[
        my_global = 42
      ]]> ).toString();
      doString(script, [ true ]);

      var stack:Array = lua_wrapper.callGlobal(
          luaState, "my_global", [ ]
        );
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

      var stack:Array = lua_wrapper.callGlobal(
          luaState, "my_global", [ ]
        );
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

      var stack:Array = lua_wrapper.callGlobal(
          luaState, "my_global", [ ]
        );
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

      var args:Array =
      [
        null,
        42,
        "forty two",
        [ true ],
        undefined
      ];

      // Note that full type conversion test is done in a separate suite.
      // Now we're just smoke-testing that all is OK.
      var stack:Array = lua_wrapper.callGlobal(
          luaState, "my_global", args
        );
      args.unshift(true);
      args[args.length - 1] = null;
      checkLuaResult(args, stack);
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

      var args:Array =
      [
        null,
        42,
        "forty two",
        [ true ],
        undefined
      ];

      // Note that full type conversion test is done in a separate suite.
      // Now we're just smoke-testing that all is OK.
      var stack:Array = lua_wrapper.callGlobal(
          luaState, "my_global", args
        );
      args.unshift(true);
      args[args.length - 1] = null;
      checkLuaResult(args, stack);
    }
  }
}
