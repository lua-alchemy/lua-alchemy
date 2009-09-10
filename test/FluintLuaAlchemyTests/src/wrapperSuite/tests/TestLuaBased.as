package wrapperSuite.tests
{
  import luaAlchemy.LuaAlchemy;

  import flash.utils.ByteArray;

  import mx.containers.Canvas;
  import mx.utils.ObjectUtil;

  import net.digitalprimates.fluint.tests.TestCase;

  // TODO: Lua should be able to extend list of test *cases* as well!

  public dynamic class TestLuaBased extends CommonLuaAlchemyTestCase
  {
    import flash.utils.*;

    import mx.collections.ICollectionView;
    import mx.collections.IViewCursor;
    import mx.collections.XMLListCollection;

    import mx.utils.*;

    public function TestLuaBased()
    {
      // We have test-specific assets
      LuaAssets.init(LuaAlchemy.libInit);

      var myLuaAlchemy:LuaAlchemy = new LuaAlchemy(LuaAssets.filesystemRoot());

      var stack:Array = myLuaAlchemy.doFile("builtin://test-lua-nucleo.lua");
      assertTrue(stack[0]);
      assertEquals(2, stack.length);

      var collection:ICollectionView = getTests();
      var cursor:IViewCursor = collection.createCursor();

      var callbacks:Object = stack[1];
      for (var key:String in callbacks)
      {
        assertTrue(callbacks[key] is Function);
        var callback:Function = callbacks[key] as Function;

        //  We have to introduce new scope here, so callback variable
        //  would not be reused.
        this[key] = (function(
            scopedKey:String,
            scopedCallback:Function
          ):Function
        {
          return function():void // TODO: Unsafe. Check names.
          {
            var resultsAny:* = scopedCallback();
            assertTrue(resultsAny is Array);
            var results:Array = resultsAny as Array;
            if (results.length == 2 && results[0] == false)
            {
              // Special case handler to enhance error message readability.
              fail(
                  "Test `" + scopedKey + "' Lua error: " + results[1].toString()
                );
            }
            else
            {
              checkLuaResult([ true ], results, true);
            }
          };
        })(key, callback);

        //  TODO: UGLY HACK!
        cursor.insert(
            new XML(
                '<method name="'
                + key
                + '" declaredBy="wrapperSuite.tests::TestLuaBased"'
                + ' returnType="void"/>'
              )
          );
      }
    }

    override protected function setUp():void
    {
      // We have test-specific assets
      myLuaAlchemy = new LuaAlchemy(LuaAssets.filesystemRoot());
    }

    public function testDummy():void
    {
      //  This test is to ensure test UI works correctly.
      //  It seems that there should be at least one
      //  test method on the time the base class is constructed.
      //  TODO: There should be more elegant workaround!
      trace("Dummy");
    }

    // TODO: Move these to other test suite(s)
    /*
    public function testCallbacksList1():void
    {
      var stack:Array = myLuaAlchemy.doString(
          (<![CDATA[
            return
              function()
                return 10
              end
          ]]>).toString()
        );
      assertTrue(stack[0]);
      assertEquals(2, stack.length);

      var cb1:Function = stack[1];
      assertEquals(10, cb1());
    }

    public function testCallbacksList2():void
    {
      var stack:Array = myLuaAlchemy.doString(
          (<![CDATA[
            return
              function()
                return 10
              end,
              function()
                return 20
              end
          ]]>).toString()
        );
      assertTrue(stack[0]);
      assertEquals(3, stack.length);

      var cb1:Function = stack[1];
      assertEquals(10, cb1());

      var cb2:Function = stack[2];
      assertEquals(20, cb2());
    }

    public function testCallbacksObject():void
    {
      var stack:Array = myLuaAlchemy.doString(
          (<![CDATA[
            return as3.toobject
            {
              cb1 = function()
                return 10
              end;
              cb2 = function()
                return 20
              end;
            }
          ]]>).toString()
        );
      assertTrue(stack[0]);
      assertEquals(2, stack.length);

      var obj:Object = stack[1];

      assertEquals(10, obj.cb1());

      var cb2:Function = stack[2];
      assertEquals(20, obj.cb2());
    }

    public function testDynamicClassSanity():void
    {
      var foo:Foo = new Foo();
      var methods:Object = { foobar1: 101, foobar2: 201, foobar3: 301 };

      // Have to introduce new scope
      var makeCallback:Function = function(result:Number):Function
      {
        return function():Number
        {
          return result;
        }
      }

      for (var key:String in methods)
      {
        foo[key] = makeCallback(methods[key])
      }

      // Prints
      // 101 = 101 201 = 201 301 = 301
      trace(
          101, "=", foo.foobar1(),
          201, "=", foo.foobar2(),
          301, "=", foo.foobar3()
        );
     }
     */
  }
}

/*
internal dynamic class Foo
{
};
*/
