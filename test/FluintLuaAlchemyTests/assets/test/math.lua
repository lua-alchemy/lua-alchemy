-- math.lua: math-related utilities
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

dofile('lua-nucleo/strict.lua')
dofile('lua-nucleo/import.lua')

local make_suite = select(1, ...)
assert(type(make_suite) == "function")

local ensure,
      ensure_equals
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_equals'
      }

local trunc,
      math_imports
      = import 'lua-nucleo/math.lua'
      {
        'trunc'
      }

--------------------------------------------------------------------------------

local test = make_suite("math", math_imports)

--------------------------------------------------------------------------------

test:tests_for "trunc"

test "trunc-basic" (function()
  ensure_equals("fractional, >0", trunc(3.14), 3)
  ensure_equals("fractional, <0", trunc(-3.14), -3)

  ensure_equals("integral, >0", trunc(42), 42)
  ensure_equals("integral, <0", trunc(-42), -42)

  ensure_equals("zero", trunc(0.00), 0)

  ensure_equals("+inf", trunc(math.huge), math.huge)
  ensure_equals("-inf", trunc(-math.huge), -math.huge)

  do
    local truncated_nan = trunc(0/0)
    ensure("nan", truncated_nan ~= truncated_nan)
  end
end)

test "trunc-random" (function()
  local num_iter = 1e6
  for i = 1, num_iter do
    local sign = (math.random() >= 0.5) and 1 or -1
    local int = math.random(2 ^ 29)
    local frac = math.random()

    local num = sign * (int + frac)

    ensure_equals("random check", trunc(num), sign * int)
  end
end)

--------------------------------------------------------------------------------

assert(test:run())
