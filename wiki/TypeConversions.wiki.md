# Introduction

When making calls across the ActionScript `<->` Lua boundary Lua types are automatically converted to ActionScript types but all data returned from ActionScript to Lua remains as ActionScript userdata until explicitly converted with a call to as3.tolua() (see LuaToAS3LowLevel).  The reason for not converting to Lua types automatically are to allow call chaining in Lua (a.b.c().d) of ActionScript objects without taking a large performance hit.

We would have to actually call as3.get() on each index operation. We would
have to call as3.type() on the result. If result is function, we throw
newly created AS3 closure away. If it is plain value, we call as3.tolua()
on it. Otherwise we return the value.

Marshalling aross the Lua`<->`C`<->`AS3 boundary each time (or dropping Lua if
we rewrite sugar in C).

If foo.bar returned a string and you did a string operation on it, wheich
returned a string, which returned a string....
you might expect to be able to call a chain of AS3 functions but it would
stop when it hit one that could convert to a Lua type and then start
calling Lua functions


**TODO:** Cleanup

There are eight types in Lua:

Simple ones:

  * nil
  * number
  * string
  * boolean

Harder ones:

  * table
  * function
  * thread
  * userdata

Note that threads in Lua are not OS threads, but coroutines --
collaborative multithreading constructs. We probably do not need to
allow Lua threads and userdata to be pass to AS (except maybe as a
"black boxes" to be passed back to Lua functions). We may implement
some AS3 types as userdata (class objects for example) -- but it would
be easy to distinguish between "our" userdata and one that come, say,
from another Lua C module.

We probably would not be able to map table to AS3 well (due to its
advanced features like metatables etc). For the sake of Lua to AS
calls it could be easier to provide explicit convertors to each of
relevant AS types

Lua: ` AS3.table2{object,array,vector,dictionary,bytearray}() `

It is probably best to avoid autoconversions here. OTOH conversion
from the relevant AS type to table should go smoothly (but maybe it
would be simple to use metatabled userdata instead, need to prototype
a bit here).

**TODO** We should decide also if bytearray actually fits here --
probably not.

# ActionScript -> Lua

Primitive types:

  * Boolean -> boolean
  * int  -> number
  * Null -> nil
  * Number -> number
  * String -> string
  * uint -> number
  * void -> nil

Complex types:

Note that userdata "type" (metatable) should be different for each
case, as there are things you can do with each type.

  * Object -> userdata, convertible to table
  * Array -> userdata, convertible to table
  * Vector -> userdata, convertible to table
  * Dictionary -> userdata, convertible to table
  * ByteArray -> userdata, convertible to table and to string
  * Function -> userdata with call metamethod (as3.new("Function")(args))

  * Error -> ???

  * MovieClip, Bitmap, Shape, TextField, SimpleButton, Date, RegExp,
Video, XML, XMLList -> the same kind of userdata as for any other
"user-supplied" AS3 class.

See also: [Data type descriptions](http://livedocs.adobe.com/flash/9.0/main/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Parts&file=00000047.html) and [Wikipedia on AS3 types](http://en.wikipedia.org/wiki/ActionScript#Data_types).

# Lua -> ActionScript

**TODO**