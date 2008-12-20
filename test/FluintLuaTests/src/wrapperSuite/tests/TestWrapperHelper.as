package wrapperSuite.tests
{
  import flash.events.Event;
  import flash.events.EventDispatcher;

  public class TestWrapperHelper extends EventDispatcher
  {
    public static const TEST_WRAPPER_HELPER_EVENT:String = "TestWrapperHelperEvent";
    public static const TEST_WRAPPER_INCREMENT_EVENT:String = "TestWrapperIncrementEvent";

    public function TestWrapperHelper()
    {
    }

    public var string1:String;

    private var _string2:String;
    public function get string2():String { return _string2; }
    public function set string2(value:String):void { _string2 = value; }

    public var nameAge:String;
    public function setNameAge(name:String, age:int):void
    {
      nameAge = staticNameAge(name, age);
    }

    public static function staticNameAge(name:String, age:int):String
    {
      return "Name: " + name + " age: " + age;
    }

    public function sendEvent():void
    {
      dispatchEvent(new Event(TEST_WRAPPER_HELPER_EVENT));
    }

    public var count:int = 0;
    public function sendIncrementEvent():void
    {
      dispatchEvent(new Event(TEST_WRAPPER_INCREMENT_EVENT));
    }

  }
}
