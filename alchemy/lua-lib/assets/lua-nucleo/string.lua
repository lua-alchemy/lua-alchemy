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

return
{
  make_concatter = make_concatter;
}
