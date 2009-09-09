-- strict.lua: tests for global environment protection
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

-- NOTE: Intentionally not using test suite,
--       as the code is too low level for that.

--
-- Testing that if global variable was there before strict is enabled,
-- it is accessible, but not declared.
--

allowed_global = 1
dofile('lua-nucleo/strict.lua')
allowed_global = 2

local a0 = allowed_global

assert(is_declared("allowed_global") == false)

-- The rest of tests

assert(is_declared("good_1") == false)
assert(is_declared("good_2") == false)
assert(is_declared("good_3") == false)
assert(is_declared("good_4") == false)
assert(is_declared("good_5") == false)
assert(is_declared("bad_1") == false)

assert(pcall(function() good_1 = 1 end) == false)
assert(pcall(function() good_2 = 2 end) == false)
assert(pcall(function() good_3 = 3 end) == false)
assert(pcall(function() good_4 = 4 end) == false)
assert(pcall(function() good_5 = 5 end) == false)

declare 'good_1'
exports 'good_2'
exports { 'good_3', 'good_4', 'good_5' }

good_1 = 1
good_2 = 2
good_3 = 3
good_4 = 4
good_5 = 5
local a1 = good_1
local a2 = good_2
local a3 = good_3
local a4 = good_4
local a5 = good_5

assert(pcall(function() bad_1 = 1 end) == false)
assert(pcall(function() local b1 = bad_1 end) == false)

assert(is_declared("allowed_global") == false)
assert(is_declared("good_1") == true)
assert(is_declared("good_2") == true)
assert(is_declared("good_3") == true)
assert(is_declared("good_4") == true)
assert(is_declared("good_5") == true)
assert(is_declared("bad_1") == false)

local expected =
{
  ["good_1"] = true;
  ["good_2"] = true;
  ["good_3"] = true;
  ["good_4"] = true;
  ["good_5"] = true;
}

for name, flag in get_declared_iter_() do
  assert(flag == true)
  assert(expected[name] == true)
  expected[name] = nil
end

assert(next(expected) == nil)
