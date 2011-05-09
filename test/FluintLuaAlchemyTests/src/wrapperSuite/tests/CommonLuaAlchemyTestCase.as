package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  public class CommonLuaAlchemyTestCase extends BaseTestCase
  {
    protected var myLuaAlchemy:LuaAlchemy;

    override protected function setUp():void
    {
      myLuaAlchemy = new LuaAlchemy(null, false);
    }

    override protected function tearDown():void
    {
      trace("TestLuaAlchemyInterface::tearDown(): begin");
      try
      {
        myLuaAlchemy.close();
        myLuaAlchemy = null;
      }
      catch (errObject:Error)
      {
        trace("TestLuaAlchemyInterface::tearDown(): error " + errObject.message);
        throw errObject;
      }
      trace("TestLuaAlchemyInterface::tearDown(): end");
    }

    protected function doString(script:String, expected:Array, verifyLength:Boolean = true):void
    {
      var stack:Array = myLuaAlchemy.doString(script);
      checkLuaResult(expected, stack, verifyLength);
    }

    protected function doFile(file:String, expected:Array, verifyLength:Boolean = true):void
    {
      var stack:Array = myLuaAlchemy.doFile(file);
      checkLuaResult(expected, stack, verifyLength);
    }

    protected function doStringAsync(
        timeout:Number,
        script:String,
        expected:Array,
        verifyLength:Boolean = true
      ):void
    {
      var settings:Object = new Object();
      settings.expected = expected;
      settings.verifyLength = verifyLength;
      var handler:Function = asyncHandler(
          asyncCallback,
          timeout,
          settings,
          timeOutCallback
        );
      myLuaAlchemy.doStringAsync(
          script,
          function(stack:Array):void
          {
            settings.stack = stack;
            handler(stack, settings);
          }
        );
    }

    protected function doFileAsync(
        timeout:Number,
        filename:String,
        expected:Array,
        verifyLength:Boolean = true
      ):void
    {
      var settings:Object = new Object();
      settings.expected = expected;
      settings.verifyLength = verifyLength;
      var handler:Function = asyncHandler(
          asyncCallback,
          timeout,
          settings,
          timeOutCallback
        );
      myLuaAlchemy.doFileAsync(
          filename,
          function(stack:Array):void
          {
            settings.stack = stack;
            handler(stack, settings);
          }
        );
    }

    protected function asyncCallback(
        stack:Array,
        settings:Object
      ):void
    {
      checkLuaResult(
          settings.expected,
          stack,
          settings.verifyLength
        );
    }

    protected function timeOutCallback(settings:Object):void
    {
      if (settings.stack) // TODO: WTF?!
      {
        checkLuaResult(
            settings.expected,
            settings.stack,
            settings.verifyLength
          );
      }
      else
      {
        fail("timed out");
      }
    }
  }
}
