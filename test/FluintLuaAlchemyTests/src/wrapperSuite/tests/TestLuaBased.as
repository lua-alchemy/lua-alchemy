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

    // WARNING: There should be at least one passing "static" test method,
    //          or fluint would not work properly.
    // TODO: There should be more elegant workaround!
    public function testDummy():void
    {
      trace("Dummy");
    }

    public function testMathRandomSanity():void
    {
      //  Based on actual bug scenario.
      var script:String = ( <![CDATA[
        math.randomseed(12345)

        for i = 1, 1e6 do
          local a, b, c =
            math.random(),
            math.random(2 ^ 29),
            math.random()

          if a < 0 or a >= 1 then
            error(i .. " bad a "..a)
          end

          if b < 1 or b > (2 ^ 29) or b % 1 ~= 0 then
            error(i .. " bad b "..b)
          end

          if c < 0 or c >= 1 then
            error(i .. " bad c "..c)
          end
        end
      ]]> ).toString();

      doString(script, [true]);
    }
  }
}
