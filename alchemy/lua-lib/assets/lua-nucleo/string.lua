-- string.lua: string-related tools
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

local table_concat = table.concat

local make_concatter
do
  make_concatter = function()
    local buf = {}

    local function cat(v)
      buf[#buf + 1] = v
      return cat
    end

    local concat = function()
      return table_concat(buf, "")
    end

    return cat, concat
  end
end

-- Remove trailing and leading whitespace from string.
-- From Programming in Lua 2 20.4
local trim = function(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local escape_string = function(str)
  return str:gsub(
      "[%c]",
      function(c)
        return ("%%%02X"):format(c:byte())
      end
    )
end

return
{
  escape_string = escape_string;
  make_concatter = make_concatter;
  trim = trim;
}
