Low level calls to the AS3 interface. LuaToAS3Sugar wraps these functions: as3.newclass(), as3.new(), as3.get(), as3.set(), and as3.call(). as3.release() frees the reference to an AS3 class and is done automatically when an object is garbage collected by Lua.

### as3.flyield()
Release control to Flash and return to this point on the next timer tick. This currently doesn't allow UI updates, but does prevent the script from timing out over long operations.

Returns true if in async mode, nil and error message otherwise.

**Note:** this function is not related to Lua coroutines.

**Note:** this function works only inside async calls (doFileAsync() and doStringAsync()).

Example
```
as3.flyield() 
```

### as3.newclass("[package::]ClassName")
Return the requested class in package::ClassName form. The return can be used to call static class functions or get/set static properties

Example
```
local v = as3.newclass("flash.utils:ByteArray") 
```

### as3.new("[package::]ClassName[, param1,... paramN]")
Create a new instance of the given class in package::ClassName form.

**Note:** Only classes that have been included in the demo can be created. At the very least all of mx.containers and mx.controls has been included along with all the top level and default classes all flash objects get.

Example
```
local v = as3.new("flash.utils:ByteArray")
local s = as3.new("String", "some string") 
```

### as3.release(this)
Release the given ActionScript object so Flash will do garbage collection.

Example
```
local v = as3.new("String")
as3.release(v) 
```

**Note:** You do not have to call this function manually — any object will eventually be garbage-collected by Lua and released. But if you want to release memory _now_, call it.

### as3.tolua(this, ...)
Convert ActionScript value to a Lua type if possible (see push\_as3\_to\_lua\_stack). Supports multiple arguments. If conversion is not possible, this will return the original AS object. If argument is a Lua value, it is returned intact.

Example
```
local v = as3.new("String", "some string")
local s, n = as3.tolua(v, 42) -- s is a Lua string with value "some string", n is a Lua number 42
```

### as3.toas3(this, ...)
Convert Lua value to a AS3 type. Supports multiple arguments. If argument is an AS3 value, it is returned intact.

Example
```
local n, f = as3.toas3(42, function() end) -- n is Number 42, f is an AS3 function 
```

### as3.get(this, "property")
Return the requested property of a given ActionScript object. The value is returned as an ActionScript type (see as3.tolua() to convert to a native Lua type)

Example
```
local v = as3.new("Array")
return as3.get(v, "length") 
```

### as3.set(this, "property", value)
Set the requested property of a given ActionScript object.

Example
```
local v = as3.new("mx.components::TextArea")
as3.set(v, "text", "hello") 
```

### as3.call(this, "function"[, param1, ... paramN])
Call a function on a given ActionScript object.  Any return values are returned as an ActionScript type (see as3.tolua() to convert to a native Lua type)

Example
```
local box = as3.new("mx.containers::Canvas")
as3.call(box, "setStyle", "backgroundColor", "blue") 
```

### as3.type(this)
Returns the ActionScript getQualifiedClassName() for the given value

Example
```
local box = as3.new("mx.containers::Canvas")
local type = as3.type(box) --> "mx.containers::Canvas" 
```

### as3.namespacecall("package", "function"[, param1, ... paramN])
Call a namespace level function.  Any return values are returned as an ActionScript type (see as3.tolua() to convert to a native Lua type)


Example
```
local v = as3.new("wrapperSuite.tests::TestWrapperHelper")
return as3.namespacecall("flash.utils", "getQualifiedClassName", v) --> wrapperSuite.tests::TestWrapperHelper 
```

### as3.trace(param1, ... paramN)
Write to Flash trace output (print-like)

Example
```
as3.trace("Hello from Lua Alchemy!") 
```

### as3.isas3value(obj)
Returns true if object is as3 value. Returns nil otherwise

Example
```
local box = as3.new("mx.containers::Canvas")
assert(as3.isas3value(box) == true) 
```