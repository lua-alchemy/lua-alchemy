-- import.lua -- minimalistic Lua submodule system
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

if exports then exports 'import' end

local type, assert, loadfile, ipairs, tostring, error, unpack
    = type, assert, loadfile, ipairs, tostring, error, unpack

do
  local import_cache = {}

  import = function(filename)
    local t
    local fn_type = type(filename)
    if fn_type == "table" then
      t = filename
    elseif fn_type == "string" then
      t = import_cache[filename]
      if t == nil then
        t = assert(assert(loadfile(filename))(), "import: bad implementation", 2)
        import_cache[filename] = t
      end
    else
      error("import: bad filename type: "..fn_type, 2)
    end

    return function(symbols)
      local result = {}
      local sym_type = type(symbols)

      if sym_type ~= "nil" then
        if sym_type == "table" then
          for i,name in ipairs(symbols) do
            local v = t[name]
            if v == nil then
              error("import: key `"..tostring(name).."' not found", 2)
            end
            result[i] = v
          end
        elseif sym_type == "string" then
          local v = t[symbols]
          if v == nil then
            error("import: key `"..symbols.."' not found", 2)
          end
          result[1] = v
        else
          error("import: bad symbols type: "..sym_type, 2)
        end

      end
      result[#result + 1] = t

      return unpack(result)
    end
  end
end
