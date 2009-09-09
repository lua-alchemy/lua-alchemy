-- algorithm.lua -- various common algorithms
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

local assert = assert
local math_floor = math.floor

local lower_bound = function(t, k, value)
  local len = #t
  local first = 1
  local middle, half
  while len > 0 do
    half = math_floor(len / 2)
    middle = first + half
    local v = assert(
        assert(t[middle], "hole in array", middle)[k],
        "value missing"
      )
    if v < value then
      first = middle + 1
      len = len - half - 1
    else
      len = half
    end
  end
  return first
end

return
{
  lower_bound = lower_bound;
}
