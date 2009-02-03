-- Lua Global Protection Module v.1.0
-- By Alexander Gladysh <agladysh@gmail.com>
-- See license at the end of file

-- Provides
--   Protection from unsanctioned access to global environment

local type, pairs, error, rawget, rawset, tostring = type, pairs, error, rawget, rawset, tostring

local declared = {}

declare = function(name)
  declared[name] = true
end

exports = function(names)
  local name_type = type(names)
  if name_type == "table" then
    for k, name in pairs(names) do
      declare(name)
    end
  elseif name_type == "string" then
    declare(names)
  else
    error("Bad type for export: " .. name_type, 2)
  end
end

is_declared = function(name)
  return declared[name] == true
end

-- Note this function is intentionally not documented
get_declared_iter_ = function()
  return pairs(declared)
end

setmetatable(_G,{
  __index = function(t, k)
    if declared[k] then
      return rawget(t, k)
    end

    error("attempted to access undeclared global: "..tostring(k), 2)
  end;

  __newindex = function(t, k, v)
    if declared[k] then
      return rawset(t, k, v)
    end

    error("attempted to write to undeclared global: "..tostring(k), 2)
  end;
})

--[[
Copyright (C) 2007-2009 Alexander Gladysh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
--]]