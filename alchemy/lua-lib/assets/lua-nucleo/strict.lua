-- strict.lua -- global environment protection
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

local type, pairs, error, rawget, rawset, tostring
    = type, pairs, error, rawget, rawset, tostring

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
