-- ensure.lua: tools to ensure correct code behaviour
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

local error, tostring, pcall, type =
      error, tostring, pcall, type

-- TODO: Write tests for this one
local ensure = function(msg, value, ...)
  return value
    or error(
        msg
        .. ((...) and (": " .. (tostring(...) or "?")) or ""),
        2
      )
end

-- TODO: Write tests for this one
local ensure_equals = function(msg, actual, expected)
  return
      (actual ~= expected)
      and error(
          msg
          .. ": actual `" .. tostring(actual)
          .. "', expected `" .. tostring(expected)
          .. "'",
          2
        )
      or actual -- NOTE: Should be last to allow false and nil values.
end

-- TODO: Write tests for this one
local ensure_tequals = function(msg, actual, expected)
  if type(expected) ~= "table" then
    error(
        msg
        .. ": bad expected type, must be `table', got `"
        .. type(expected) .. "'",
        2
      )
  end

  if type(actual) ~= "table" then
    error(
        msg
        .. ": bad actual type, expected `table', got `"
        .. type(actual) .. "'",
        2
      )
  end

  -- TODO: Employ tdiff() (when it would be written)

  for k, expected_v in pairs(expected) do
    local actual_v = actual[k]
    if actual_v ~= expected_v then
      error(
          msg
          .. ": bad actual value at key `" .. tostring(k)
          .. "': got `" .. tostring(actual_v)
          .. "', expected `" .. tostring(expected_v)
          .. "'",
          2
        )
    end
  end

  for k, actual_v in pairs(actual) do
    if expected[k] == nil then
      error(
          msg
          .. ": unexpected actual value at key `" .. tostring(k)
          .. "': got `" .. tostring(actual_v)
          .. "', should be nil",
          2
        )
    end
  end

  return actual
end

-- TODO: Write tests for this one
local ensure_fails_with_substring = function(msg, fn, substring)
  local res, err = pcall(fn)

  if res ~= false then
    error(msg .. ": call not failed as expected")
  end

  if type(err) ~= "string" then
    error(msg .. ": call failed with non-string error")
  end

  if not err:find(substring) then
    error(
        msg
        .. ": can't find expected substring `" .. tostring(substring)
        .. "' in error message:\n" .. err
      )
  end
end

return
{
  ensure = ensure;
  ensure_equals = ensure_equals;
  ensure_tequals = ensure_tequals;
  ensure_fails_with_substring = ensure_fails_with_substring;
}
