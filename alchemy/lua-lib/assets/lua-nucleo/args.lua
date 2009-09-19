-- args.lua --utils that deal with function arguments
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)


local nargs = function(...)
  return select("#", ...), ...
end

local pack = function(...)
  return select("#", ...), { ... }
end

return
{
  pack=pack;
  nargs=nargs
}