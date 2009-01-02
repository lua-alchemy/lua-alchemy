-- Save overridden functions just in case
local old_print, old_dofile, old_loadfile = print, dofile, loadfile

-- Note: sugar relies on this variable
as3.canvas = assert(_G["_LUA_ALCHEMY_CANVAS"], "missing canvas")

-- TODO: Also add global environment protection!
old_dofile("builtin://core/sugar.lua")
old_dofile("builtin://core/file_get_contents.lua")

print = as3.trace -- Note: it is important to have sugared version here

do
  local BUILTIN_PREFIX = "builtin://"

  local filesystem_root = _G["_LUA_ALCHEMY_FILESYSTEM_ROOT"] or BUILTIN_PREFIX
  local filesystem_prefix = filesystem_root:match("^([a-z_-]+://)")
  if not filesystem_prefix then
    error("missing prefix in _LUA_ALCHEMY_FILESYSTEM_ROOT: `"..filesystem_root.."`")
  end

  loadfile = function(filename)
    -- Note: We do not support loadfile() which supposed to load from stdin.
    -- TODO: Load from open file dialog then?
    if type(filename) ~= "string" then
      -- TODO: Match error message with old_loadfile
      return nil, "bad filename type, string expected, got "..type(filename)
    end

    local orig_filename = filename
    local orig_prefix = filename:match("^([a-z_-]+://)")

    local prefix = orig_prefix
    if not prefix then
      -- If we do not have prefix in filename, use system prefix.
      filename = filesystem_root .. filename
      prefix = filesystem_prefix
    end

    local res, err

    if prefix == BUILTIN_PREFIX then
      res, err = old_loadfile(filename) -- Builtin prefix loaded with old loadfile
    elseif prefix then
      res, err = as3.tolua(as3.file_get_contents(filename))
      if res ~= nil then
        res, err = loadstring(res, "@"..filename)
      end

      if res == nil and not orig_prefix then
        -- If load failed, and there was no orig_prefix,
        -- try loading using builtin prefix.
        as3.trace("fallback to builtin loadfile on", orig_filename)
        local err2
        res, err2 = old_loadfile(BUILTIN_PREFIX .. orig_filename)
        if res == nil then
          -- TODO: Tune this message
          err = err .. "\nalso failed load from builtin:\n" .. err2
        end
      end
    end

    return as3.tolua(res, err)
  end

  dofile = function(filename)
    return assert(loadfile(filename))()
  end
end

dofile("main.lua")
