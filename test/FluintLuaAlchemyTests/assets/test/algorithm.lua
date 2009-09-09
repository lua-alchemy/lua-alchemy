-- algorithm.lua: tests for various common algorithms
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

dofile('lua-nucleo/strict.lua')
dofile('lua-nucleo/import.lua')

local make_suite = select(1, ...)
assert(type(make_suite) == "function")

local ensure_equals = import 'lua-nucleo/ensure.lua' { 'ensure_equals' }
local tdeepequals = import 'lua-nucleo/tdeepequals.lua' { 'tdeepequals' }

local lower_bound,
      algorithm
      = import 'lua-nucleo/algorithm.lua'
      {
        'lower_bound'
      }

--------------------------------------------------------------------------------

local test = make_suite("algorithm", algorithm)

--------------------------------------------------------------------------------

test:test_for "lower_bound" (function()
  -- TODO: Test it better

  local check = function(t, k, expected_value)
    local actual_value = lower_bound(t, 1, k)
    if actual_value ~= expected_value then
      error(
          ("check lower_bound: bad actual value %q, expected %q\n"):format(
              tostring(actual_value), tostring(expected_value)
            )
        )
    end
  end

  check({ {1}, {2} }, 1.5, 2)
  check({ {1}, {2} }, 0, 1)
  check({ {1}, {2} }, 1, 1)
  check({ {1}, {2} }, 2, 2)
  check({ {1}, {2} }, 3, 3)
end)

--------------------------------------------------------------------------------

assert(test:run())
