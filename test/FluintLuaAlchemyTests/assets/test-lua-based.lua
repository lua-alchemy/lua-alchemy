-- TODO: Generalize to as3.protectcallback()?
-- Protect callback return value follows lua.doString() convention.
local protectcallback = function(fn)
  return function(...)
    return as3.argstoarray(pcall(fn, ...))
  end
end

local tests = { }

tests["testLuaBasedDummy"] = protectcallback(function()
  -- Dummy
end)

return as3.toobject(tests)
