-- tserialize-test-utils.lua -- utility functions for tserialize testing
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)



local randomseed = 1235134892
--local randomseed = os.time()

math.randomseed(randomseed)
-- ----------------------------------------------------------------------------
-- Utility functions
-- ----------------------------------------------------------------------------
assert(type(import)=="function","Import is required to run")
local tdeepequals = import("lua-nucleo/tdeepequals.lua") {'tdeepequals'}
local invariant = function(v)
  return function()
    return v
  end
end

local escape_string = function(str)
  return str:gsub(
      "[^0-9A-Za-z_%- :]",
      function(c)
        return ("%%%02X"):format(c:byte())
      end
    )
end

local ensure_equals = function(msg, actual, expected)
  if actual ~= expected then
    error(
        msg..": actual `"..escape_string(tostring(actual))
        .."` expected `"..escape_string(tostring(expected)).."'"
      )
  end
end



local nargs = function(...)
  return select("#", ...), ...
end

local pack = function(...)
  return select("#", ...), { ... }
end


-- ----------------------------------------------------------------------------
-- Test helper functions
-- ----------------------------------------------------------------------------

local tserialize = import 'lua-nucleo/tserialize.lua' {"tserialize"}

local check_fn_ok = function(eq, ...)
  local saved = tserialize(...)
  assert(type(saved) == "string")
  print("saved length", #saved, "(display truncated to 1000 chars)")
  print(saved:sub(1, 1000))
  local expected = { ... }
  local loaded = { assert(loadstring(saved))() }
  assert(eq(expected, loaded), "tserialize produced wrong table!")
  return saved
end


local check_ok = function(...)
  print("check_ok started")
  local ret=check_fn_ok(tdeepequals, ...)
  if ret then
    print("check_ok successful")
    return true
  else
    print("check_ok failed")
    return false
  end
end

return {check_ok=check_ok}
