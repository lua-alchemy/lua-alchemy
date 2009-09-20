-- args.lua: tests for various utilities related to function arguments
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

dofile('lua-nucleo/strict.lua')
dofile('lua-nucleo/import.lua')

local make_suite = select(1, ...)
assert(type(make_suite) == "function")

local ensure_equals = import 'lua-nucleo/ensure.lua' { 'ensure_equals' }

local nargs,
      pack
      = import 'lua-nucleo/args.lua'
      {
	'nargs',
	'pack'
      }

--------------------------------------------------------------------------------

local test = make_suite("args")

--------------------------------------------------------------------------------

test:tests_for "nargs"

test "nargs minimal" (function()
  local t1="a";
  local t2="b";
  local t3="c";
  ensure_equals("args number", nargs(t1,t2,t3),3)
  ensure_equals("args number", table.concat({nargs(t1,t2,t3)}),"3abc")
end)

--------------------------------------------------------------------------------
test:tests_for "pack"

test "pack minimal" (function()
  local t1="a";
  local t2="b";
  local t3="c";
  ensure_equals("args number", pack(t1,t2,t3),3)
  local num, tbl = pack(t1,t2,t3)
  ensure_equals("args number", table.concat(tbl),"abc")
end)
--------------------------------------------------------------------------------


assert(test:run())
