dofile("builtin://lua_alchemy.lua")

-- TODO: Generalize to as3.protectcallback()?
-- Protect callback return value follows lua.doString() convention.
local protectcallback = function(fn)
  return function(...)
    return as3.argstoarray(pcall(fn, ...))
  end
end

-- All tests must have "test" prefix in their name.
local tests = { }

-- Needed to disprove actual bug report (related to #149)
tests["testLoadStringIsThere"] = protectcallback(function()
  if not type(loadstring) == "function" then
    return error(
        "loadstring global should be function but instead is "
     .. type(loadstring)
      )
  end
  local code = assert(
      loadstring([[return 42]], "@testLoadStringIsThere"),
      "loadstring can compile code"
    )
  assert(type(code) == "function", "loadstring compiles code to function")
  assert(code() == 42, "compiled code works as expected")
end)

return as3.toobject(tests)
