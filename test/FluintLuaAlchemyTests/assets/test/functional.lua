-- functional.lua -- tests for the functional module
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

dofile('lua-nucleo/strict.lua')
dofile('lua-nucleo/import.lua')

local make_suite = select(1, ...)
assert(type(make_suite) == "function")

local ensure_equals = import 'lua-nucleo/ensure.lua' { 'ensure_equals' }
local tdeepequals = import 'lua-nucleo/tdeepequals.lua' { 'tdeepequals' }

local do_nothing,
      identity,
      invariant,
      functional =
      import 'lua-nucleo/functional.lua'
      {
        'do_nothing',
        'identity',
        'invariant'
      }

--------------------------------------------------------------------------------

local test = make_suite("functional", functional)

--------------------------------------------------------------------------------

test:test_for "do_nothing" (function()
  do_nothing() -- Just a smoke test
end)

--------------------------------------------------------------------------------

test:test_for "identity" (function()
  local e_nil,
        e_boolean,
        e_number,
        e_string,
        e_table,
        e_function,
        e_thread,
        e_userdata =
        nil,
        true,
        42,
        "identity",
        { 42 },
        function() end,
        coroutine.create(function() end),
        newproxy()

  local a_nil,
        a_boolean,
        a_number,
        a_string,
        a_table,
        a_function,
        a_thread,
        a_userdata,
        a_nothing =
        identity(
            e_nil,
            e_boolean,
            e_number,
            e_string,
            e_table,
            e_function,
            e_thread,
            e_userdata
          )

  ensure_equals("nil", a_nil, e_nil)
  ensure_equals("boolean", a_boolean, e_boolean)
  ensure_equals("number", a_number, e_number)
  ensure_equals("string", a_string, e_string)
  ensure_equals("table", a_table, e_table) -- Note direct equality
  ensure_equals("function", a_function, e_function)
  ensure_equals("thread", a_thread, e_thread)
  ensure_equals("userdata", a_userdata, e_userdata)

  ensure_equals("no extra args", a_nothing, nil)
end)

--------------------------------------------------------------------------------

test:test_for "invariant" (function()
  local data =
  {
    n = 8; -- Storing size explicitly due to hole in table.
    nil;
    true;
    42;
    "invariant";
    { 42 };
    function() end;
    coroutine.create(function() end);
    newproxy();
  }

  for i = 1, data.n do
    local inv = invariant(data[i])
    assert(type(inv) == "function")
    ensure_equals(
        "invariant "..type(data[i]),
        inv(),
        data[i]
      )
  end
end)

--------------------------------------------------------------------------------

assert(test:run())
