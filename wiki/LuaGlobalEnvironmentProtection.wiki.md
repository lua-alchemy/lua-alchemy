## Global Environment Protection

In Lua variables are global by default. Access to inexistent global variable does not trigger any error -- it simply returns nil. This is not a bad thing, and sometimes it is very useful, but sometimes it may be a bit annoying:

```
  local color = true
  if colour == true then -- Note the typo
    print("Now in color!")
  else
    print("Huh?") -- This line would be printed
  end
```

Several techniques can be used to alleviate this issue. Lua Alchemy provides the simplest one: runtime global environment protection via metatables. It is off by default. To enable it, do

```
dofile("builtin://lua-alchemy/lua/strict.lua")
```

Make sure that file `alchemy/lua-lib/assets/lua-alchemy/lua/strict.lua` is embedded inside your swf.

Lua Alchemy's Strict module triggers run-time error on  read and write access to previously not defined variables, if such variable was not previously "declared" as a "legal" global variable.

Note that Strict module does not detect any access to existing globals -- only to new ones.

### See also

  * http://lua-users.org/wiki/LuaScoping
  * http://lua-users.org/wiki/DetectingUndefinedVariables

## Module documentation

### declare(name)

Declare a global variable

```
declare("foo")
foo = 42
```

### exports(names)

Declare a list of global variables

```
exports({"foo", "bar", "baz"})
foo, bar, baz = 1, 2, 3
```

### is\_declared(name)

Detect if global variable was declared. Note the difference between "declared" and "defined". If you need to detect if a given global variable was both defined **and** declared, do as in example (`not not` converts to boolean):

```
local declared_and_defined = is_declared("foo") and (not not foo)
```