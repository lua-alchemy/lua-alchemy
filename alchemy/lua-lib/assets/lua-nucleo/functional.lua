-- functional.lua -- functional module
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

local do_nothing = function() end

local identity = function(...) return ... end

-- TODO: Backport advanced version with caching for primitive types
local invariant = function(v)
  return function()
    return v
  end
end

return
{
  do_nothing = do_nothing;
  identity = identity;
  invariant = invariant;
}
