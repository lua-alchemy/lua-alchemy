package wrapperSuite.tests
{
  import flash.utils.ByteArray;

  import luaAlchemy.lua_wrapper;
  import cmodule.lua_wrapper.CLibInit;

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

      assertTrue(stack[0]);
      assertEquals(42, stack[1]);
      assertEquals(2, stack.length);
    }

    public function testDoFileNoFile():void
    {
      var stack:Array = lua_wrapper.doFile(luaState, "no such file");

      assertFalse(stack[0]);
      assertEquals("cannot open no such file: No such file or directory", stack[1]);
      assertEquals(2, stack.length);
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

      assertFalse(stack[0]);
      assertEquals("myFileSyntaxError.lua:2: '=' expected near 'code'", stack[1]);
      assertEquals(2, stack.length);
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

      assertFalse(stack[0]);
      assertEquals("myFileRuntimeErrorString.lua:2: my runtime error\nstack traceback:\n\t[C]: in function 'error'\n\tmyFileRuntimeErrorString.lua:2: in main chunk", stack[1]);
      assertEquals(2, stack.length);
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

      assertFalse(stack[0]);
      assertEquals("table", stack[1]); // TODO: Should be a black-boxed object
      assertEquals(2, stack.length);
    }
  }
}
