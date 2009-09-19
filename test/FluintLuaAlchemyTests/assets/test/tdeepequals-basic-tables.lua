-- tdeepequals-basic-tables.lua: basic table tests for tdeepequals
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

dofile('lua-nucleo/strict.lua')
dofile('lua-nucleo/import.lua')

local make_suite = select(1, ...)
assert(type(make_suite) == "function")

local check_ok  = import 'test/lib/tdeepequals-test-utils.lua' { 'check_ok' }

---------------------------------------------------------------------------

local test = make_suite("basic tables")

---------------------------------------------------------------------------

test "1" ( function() check_ok({}, {},true) end)
test "2" ( function() check_ok({1}, {2},false) end)
test "3" ( function() check_ok({1, 2}, {2, 1}, false) end)
test "4" ( function() check_ok({1, 2, 4, 7}, {1, 2, 4, 7}, true) end)
test "5" ( function() check_ok({1, 2, {1, 2}}, {1, {1, 2}, 2}, false) end)

test "6" ( function()
  local t1 = {[{}] = 1, [{}] = 2}
  local t2 = {[{}] = 2, [{}] = 1}
  check_ok(t1, t2, true)
end)

test "7" ( function()
  local t1 = {[{}] = 1, [{}] = 2}
  local t2 = {[{}] = 1, [{}] = 1}
  check_ok(t1, t2, false)
end)

test "8" ( function()
  local t1 = {[{1, 2}] = 1, [{1, 2}] = 1}
  local t2 = {[{1, 2}] = 1, [{1, 2}] = 1}
  check_ok(t1, t2, true)
end)

test "9" ( function()
  local t1 = {[{1, 2, [{true}] = 4}] = 3, [{1, 2, [{1}] = 2}] = 2,
    [{1, 2}] = 1}
  local t2 = {[{1, 2}] = 1, [{1, 2, [{1}] = 2}] = 2, [{1, 2,
    [{true}] = 4}] = 3}
  check_ok(t1, t2, true)
end)


test "10" ( function()
  local t1 = {[{1, 2, [{true}] = 4}] = 3, [{1, 2, [{1}] = 2}] = 2,
    [{1, 2}] = 1}
  local t2 = {[{1, 2}] = 1, [{1, 2, [{2}] = 2}] = 2, [{1, 2,
    [{true}] = 4}] = 3}
  check_ok(t1, t2, false)
end)


test "11" ( function()
  local t1 = {1, 2, 3}
  local t2 = {1, 2}
  check_ok(t1,t2,false)
end)

---------------------------------------------------------------------------

assert(test:run())
