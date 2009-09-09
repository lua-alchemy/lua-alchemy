-- math.lua: math-related utilities
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

local math_ceil, math_floor = math.ceil, math.floor

--
-- Drops fractional part of a number
--
-- trunc(1.x)  -->  1
-- trunc(-1.x) --> -1
--
-- ceil(1.x)   -->  2
-- ceil(-1.x)  --> -1
--
-- floor(1.x)  -->  1
-- floor(-1.x) --> -2
--
-- TODO: Why not 'return (math.modf(n))'? Do benchmark.
local trunc = function(n)
  return ((n < 0) and math_ceil or math_floor)(n)
end

return
{
  trunc = trunc;
}
