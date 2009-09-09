-- language.lua: Lua language data
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

local lua51_keywords =
{
  ["and"] = true,    ["break"] = true,  ["do"] = true,
  ["else"] = true,   ["elseif"] = true, ["end"] = true,
  ["false"] = true,  ["for"] = true,    ["function"] = true,
  ["if"] = true,     ["in"] = true,     ["local"] = true,
  ["nil"] = true,    ["not"] = true,    ["or"] = true,
  ["repeat"] = true, ["return"] = true, ["then"] = true,
  ["true"] = true,    ["until"] = true,  ["while"] = true
}

local lua51_types =
{
  ["nil"] = true;
  ["boolean"] = true;
  ["number"] = true;
  ["string"] = true;
  ["table"] = true;
  ["thread"] = true;
  ["userdata"] = true;
}

return
{
  lua51_keywords = lua51_keywords;
  lua51_types = lua51_types;
}
