package wrapperSuite.tests
{
  import flash.utils.ByteArray;

  import luaAlchemy.lua_wrapper;
  import cmodule.lua_wrapper.CLibInit;

  import net.digitalprimates.fluint.tests.TestCase;

  public class TestWrapper extends CommonTestCaseWrapper
  {
    public function TestWrapper()
    {
      super();
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
  }
}
