-- test.lua: tests for all modules of the library
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

-- WARNING: do not use import in this file for the test purity reasons.
local run_tests = assert(assert(assert(loadfile('lua-nucleo/suite.lua'))()).run_tests)

-- TODO: Ensure each test is run in pristine environment!
--       In particular that import does not leak in from other tests.
--       Use (but ensure it is compatible with strict module):
--         setfenv(
--             setmetatable(
--                 { },
--                 { __index = _G; __newindex = _G; __metatable = true; }
--               )
--           )

-- TODO: Also preserve random number generator's seed
--       (save it and restore between suites)

local tests_pr =
{
  'suite';
  'strict';
  'import';
  --
  'tserialize-basic';
  'tserialize-recursive';
  'tserialize-metatables';
  'tserialize-autogen';
  --
  'tdeepequals-basic-types';
  'tdeepequals-basic-tables';
  'tdeepequals-recursive';
  'tdeepequals-userdata-functions-threads';
  'tdeepequals-autogen';
  --
  'table-utils';
  'table';
  --
  'coro';
  'functional';
  'algorithm';
  'math';
  'string';
  --
  'util/anim/interpolator';
}

local strict_mode = false
local n = 1
if select(n, ...) == "--strict" then
  strict_mode = true
  n = 2
end

local pattern = select(n, ...) or ""
assert(type(pattern) == "string")

local test_r = {}
for _, v in ipairs(tests_pr) do
  -- Checking directly to avoid escaping special characters (like '-')
  -- when running specific test
  if v == pattern or string.match(v, pattern) then
    test_r[#test_r + 1] = v
  end
end

if #test_r == 0 then
  error("no tests match pattern `" .. pattern .. "'")
end

if pattern ~= "" then
  print(
      "Running " .. #test_r .. " test(s) matching pattern `" .. pattern .. "'"
     )
end

run_tests(test_r, strict_mode)
