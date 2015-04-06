These functions are implemented in Lua.

If you do not need this functionality, you may strip it. See UsingRawLuaAlchemy.

### as3.onclose(function)
Function to call when LuaAlchemy#close() is called.  This will typically be used to call removeListener() and do any other necessary AS3 cleanup. You may register any number of such callbacks by calling `as3.onclose()` multiple times. Callbacks would be called in the same order as they were added.
Example
```
as3.onclose(
  function(e)
    timer.stop()
    timer.removeEventListener(as3.class.flash.events.TimerEvent.TIMER, movebox)
  end)
```

**Note:** Flash doesn't reliably call anything when a Flex application is closed so the intention of this function is to do cleanup when you are creating and closing LuaAlchemy objects numerous times during a single instance of Flash.  The cleanup is less important on shutdown of Flash since everything is stopped and all memory is recovered.

### as3.makeprinter(output)
Returns print-like function, which appends its arguments to `output.text`, where output is arbitrary as3 object. Arguments are concatenated by the rules of Lua `print()` function.

Example
```
myprint = as3.makeprinter(output)
myprint("Hello from Lua")
```

### as3.prints(...)

Returns a string, with arguments concatenated by the rules Lua `print()` function.

Example
```
local str = as3.prints("The meaning of life:", 42) --> "The meaning of life: 42"
```

### as3.filegetcontents(file)

This function currently does not work due to flyield() problem. It would be documented after problem is resolved.

TODO.

See also AutoAssets and "Modular sources and File IO" section in CoreLuaLibraries.

### as3.toobject(t)

Retuns AS3 `Object` (associative array), created from the given table.

Handles nested tables. Detects recursive tables (and raises error). Raises error if table contains non-string keys. Note that numeric keys are intentionally not converted to strings to avoid confusion (in Lua these keys are different: `{[1] = true}` and `{["1"] = true}`).

Example:
```
local object = as3.toobject({name = "NAME", param = { value = 42 } }) --> { name: "NAME", param: { value: 42 } }
```

### as3.toarray(t)

Returns AS3 `Array` object, created from the given table.

Takes in account array part of the table only (as per `ipairs()` rules). Handles nested tables. Detects recursive tables (and raises error). Converts one-based Lua arrays to zero-based AS3 arrays.

Example
```
local array = as3.toarray({ "one", "two", { 42 }) --> ["one", "two", [42]]
```