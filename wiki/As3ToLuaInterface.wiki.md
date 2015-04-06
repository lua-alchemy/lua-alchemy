# ActionScript To Lua Interface

## LuaAlchemy#LuaAlchemy(virtualFilesystemRoot:`*` = null)
Create and init() a new Lua interpreter

@param virtualFilesystemRoot The root of virtual file system (default "builtin://")

@see init()

## LuaAlchemy#init(virtualFilesystemRoot:`*` = null):void
Initialize the Lua interpreter.  If already initialized, it will be closed
and then initialized.

@param virtualFilesystemRoot The new root of virtual file system (optional)

@see close()

## LuaAlchemy#close():void (since v0.3)
/Close the Lua interpreter and cleanup.

## LuaAlchemy#doFileAsync(strFileName:String, handler:Function):void
Run the given file.  Calls callback when done.
Callback should accept a single Array argument with
the results of the call.  The first return value is true/false based on
if the string is successfully run.  If successful, the remaining values
are the Lua return values.  If failed, the second value is the error.
Note at this time you can only run AutoAssets files.

Asynchronous version.

@param strFileName The name of file to run.

@param handler The callback function.

@return The Lua return call stack.

## LuaAlchemy#doStringAsync(strValue:String, handler:Function):Array (since v0.3)
Run the given string.  Calls callback when done.
Callback should accept a single Array argument with
the results of the call.  The first return value is true/false based on
if the string is successfully run.  If successful, the remaining values
are the Lua return values.  If failed, the second value is the error.

Asynchronous version.

@param strValue The string to run.

@param handler The callback function.

@return The Lua return call stack.

## LuaAlchemy#doFile(strFileName:String):Array
Run the given file.  Returns an array of values represting
the results of the call.  The first return value is true/false based on
if the string is successfully run.  If sucessful, the remaining values
are the Lua return values.  If failed, the second value is the error.
Note at this time you can only run AutoAssets files.

@param strFileName The name of file to run.

@return The Lua return call stack.

## LuaAlchemy#doString(strValue:String):Array
Run the given string.  Returns an array of values represting
the results of the call.  The first return value is true/false based on
if the string is sucessfully run.  If sucessful, the remaining values
are the Lua return values.  If failed, the second value is the error.

@param strValue The string to run.

@return The Lua return call stack.

## LuaAlchemy#callGlobal(key:String, ... args):Array (since v0.3.1)
Synchronously call a global Lua function.

Arguments are converted to native Lua types if possible.

@param key The name of a function to call

@param args Arguments to be passed to the function.

@return The Lua return call stack.

## LuaAlchemy#setGlobal(key:String, value:`*`):void
Set a global Lua variable with the key/value pair.  The value is not converted to a native Lua type.

@param key The name of the new global variable
@param value The global value

## LuaAlchemy#setGlobalLuaValue(key:String, value:`*`):void
Set a global Lua variable with the key/value pair.  The value is converted to a Lua type if possible.

@param key The name of the new global variable
@param value The global value

## LuaAlchemy#supplyFile(name:String, data:ByteArray):void
Supply a ByteArray as a file in Lua

@param name The name of the file within Lua

@param data The contents of the file