-- string.lua: tests for string-related tools
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

local make_concatter,
      string_imports
      = import 'lua-nucleo/string.lua'
      {
        'make_concatter'
      }

--------------------------------------------------------------------------------

local test = make_suite("string", string_imports)

--------------------------------------------------------------------------------

test:tests_for "make_concatter"

test "make_concatter-basic" (function()
  local cat, concat = make_concatter()

  ensure_equals("cat is function", type(cat), "function")
  ensure_equals("concat is function", type(concat), "function")

  ensure_equals("cat returns self", cat("42"), cat)
  ensure_equals("concat on single element", concat(), "42")
end)

test "make_concatter-empty" (function()
  local cat, concat = make_concatter()

  ensure_equals("concat on empty data is empty string", concat(), "")
end)

test "make_concatter-simple" (function()
  local cat, concat = make_concatter()

  cat "a"
  cat "bc" (42)
  cat "" "d" ""

  ensure_equals("concat", concat(), "abc42d")
end)

test "make_concatter-embedded-zeroes" (function()
  local cat, concat = make_concatter()

  cat "a" "\0" "bc\0" "def\0"

  ensure_equals("concat", concat(), "a\0bc\0def\0")
end)

--------------------------------------------------------------------------------

assert(test:run())
