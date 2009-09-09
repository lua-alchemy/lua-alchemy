-- suite.lua: a simple test suite test
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

-- TODO: Test run_tests
-- TODO: Test make_suite with imports_list argument and related methods.
-- TODO: Test strict mode

local make_suite = select(1, ...)

dofile('lua-nucleo/strict.lua')
-- Note we do not use import() here.

assert(type(make_suite) == "function")

assert(pcall(function() make_suite() end) == false)

do
  local test = make_suite("test")
  assert(type(test) == "table")

  assert(pcall(function() test "a" (false) end) == false)

  local to_call = { ["1"] = true, ["2"] = true, ["3"] = true }
  local next_i = 1

  assert(to_call['1'] == true)
  test '1' (function() if next_i ~= 1 then next_i = false else next_i = 2 end to_call['1'] = nil end)
  assert(to_call['1'] == true)

  assert(test:run() == true)
  assert(to_call['1'] == nil)
  assert(next_i == 2)

  to_call['1'] = true
  next_i = 1

  test '2' (function() if next_i ~= 2 then next_i = false else next_i = 3 end to_call['2'] = nil error("this error is expected") end)
  test '3' (function() if next_i ~= 3 then next_i = false else next_i = true end  to_call['3'] = nil end)

  assert(to_call['2'] == true)
  assert(to_call['3'] == true)

  assert(test:run() == false)

  assert(next_i == true)
  assert(next(to_call) == nil)
end
