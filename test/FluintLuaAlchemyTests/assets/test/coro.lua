-- coro.lua: tests for coroutine module extensions
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

-- TODO: Backport ensure (from masha2)

-- TODO: Test pcall indeed caches functions with weak keys -- that they are
--       collected properly.

-- TODO: Benchmark coroutine.pcall against regular pcall.

dofile('lua-nucleo/strict.lua') -- Import module requires strict
dofile('lua-nucleo/import.lua') -- Import module should be loaded manually

local select, assert, type, tostring = select, assert, type, tostring
local table_concat = table.concat
local coroutine_create, coroutine_yield, coroutine_status, coroutine_resume =
      coroutine.create, coroutine.yield, coroutine.status, coroutine.resume

local make_suite = select(1, ...)
assert(type(make_suite) == "function")

local ensure,
      ensure_equals,
      ensure_tequals,
      ensure_fails_with_substring
      = import 'lua-nucleo/ensure.lua'
      {
        'ensure',
        'ensure_equals',
        'ensure_tequals',
        'ensure_fails_with_substring'
      }

local make_concatter = import 'lua-nucleo/string.lua' { 'make_concatter' }

local coro = import 'lua-nucleo/coro.lua' ()

--------------------------------------------------------------------------------

local eat_true = function(v, ...)
  if v ~= true then
    error("can't eat true:\n"..tostring(...), 2)
  end
  return ...
end

local eat_tag = function(v, ...)
  if not coro.is_outer_yield_tag(v) then
    error("can't eat outer yield tag, it is: "..tostring(v), 2)
  end
  return ...
end

local eat_true_tag = function(...)
  return eat_tag(eat_true(...))
end

--------------------------------------------------------------------------------

local test = make_suite("coro", coro)

--------------------------------------------------------------------------------

-- NOTE: Tests below check all these functions in conjunction,
--       so we're simply declaring them here as tested.
--       When adding function to this list, make sure it has tests first.

test:tests_for 'resume_inner'
               'yield_outer'
               'pcall'

--------------------------------------------------------------------------------

test "yield_inner" (function()
  local co = coroutine_create(function(A)
    ensure_equals("A", A, "A")
    ensure_equals("C", coroutine_yield("B"), "C")
    return "D"
  end)

  ensure_equals("B", eat_true(coro.resume_inner(co, "A")), "B")
  ensure_equals("D", eat_true(coro.resume_inner(co, "C")), "D")
  ensure_equals("coroutine dead", coroutine_status(co), "dead")
end)

--------------------------------------------------------------------------------

test "yield_outer" (function()
  local co = coroutine_create(function(A)
    ensure_equals("A", A, "A")
    ensure_equals("C", coro.yield_outer("B"), "C")
    return "D"
  end)

  ensure_equals("B", eat_true_tag(coroutine_resume(co, "A")), "B")
  ensure_equals("D", eat_true(coro.resume_inner(co, "C")), "D")
  ensure_equals("coroutine dead", coroutine_status(co), "dead")
end)

--------------------------------------------------------------------------------

test "inner-inner-yield_inner" (function()

  local inner1 = coroutine_create(function(A)
    assert(A == "A")

    local inner2 = coroutine_create(function(B)
      assert(B == "B")

      assert(coroutine_yield("C") == "D")

      return "E"
    end)

    assert(eat_true(coro.resume_inner(inner2, "B")) == "C")
    assert(eat_true(coro.resume_inner(inner2, "D")) == "E")
    assert(coroutine_status(inner2) == "dead")

    return "F"
  end)

  assert(eat_true(coro.resume_inner(inner1, "A")) == "F")
  assert(coroutine_status(inner1) == "dead")

end)

--------------------------------------------------------------------------------

test "outer-inner-inner-yield_outer" (function()

  local outer = coroutine_create(function(A)
    ensure_equals("A", A, "A")

    local inner1 = coroutine_create(function(B)
      ensure_equals("B", B, "B")

      local inner2 = coroutine_create(function(C)
        ensure_equals("C", C, "C")

        ensure_equals("E", coro.yield_outer("D"), "E")

        return "F"
      end)

      ensure_equals("F", eat_true(coro.resume_inner(inner2, "C")), "F")
      ensure_equals("inner2 dead", coroutine_status(inner2), "dead")

      return "G"
    end)

    ensure_equals("G", eat_true(coro.resume_inner(inner1, "B")), "G")
    ensure_equals("inner1 dead", coroutine_status(inner1), "dead")

    return "H"
  end)

  ensure_equals("D", eat_true_tag(coroutine_resume(outer, "A")),"D")
  ensure_equals("H", eat_true(coroutine_resume(outer, "E")), "H")
  ensure_equals("outer dead", coroutine_status(outer), "dead")

end)

--------------------------------------------------------------------------------

test "outer-inner-inner-yield_outer-twice" (function()

  local outer = coroutine_create(function(A)
    ensure_equals("A", A, "A")

    local inner1 = coroutine_create(function(B)
      ensure_equals("B", B, "B")

      local inner2 = coroutine_create(function(C)
        ensure_equals("C", C, "C")

        ensure_equals("E", coro.yield_outer("D"), "E")
        ensure_equals("G", coro.yield_outer("F"), "G")

        return "H"
      end)

      ensure_equals("H", eat_true(coro.resume_inner(inner2, "C")), "H")
      ensure_equals("inner2 dead", coroutine_status(inner2), "dead")

      return "I"
    end)

    ensure_equals("F", eat_true(coro.resume_inner(inner1, "B")), "I")
    ensure_equals("inner1 dead", coroutine_status(inner1), "dead")

    return "J"
  end)

  ensure_equals("D", eat_true_tag(coroutine_resume(outer, "A")), "D")
  ensure_equals("J", eat_true_tag(coroutine_resume(outer, "E")), "F")
  ensure_equals("J", eat_true(coroutine_resume(outer, "G")), "J")
  ensure_equals("outer dead", coroutine_status(outer), "dead")

end)

--------------------------------------------------------------------------------

test "pcall-error-handling" (function()
  local pcall = coro.pcall

  local status, err = pcall(function() error("BOO!") end)
  ensure_equals("status check", status, false)
  assert(err:find("BOO!"), "message check")
end)

--------------------------------------------------------------------------------

test "pcall-no-error-no-yield" (function()
  local pcall = coro.pcall

  local status, C, D = pcall(
      function(A, B)
        assert(A == "A")
        assert(B == "B")
        return "C", "D"
      end,
      "A", "B"
    )

  assert(status == true)
  assert(C == "C")
  assert(D == "D")
end)

--------------------------------------------------------------------------------

test "yield_outer-across-pcall" (function()
  local pcall = coro.pcall

  local outer = coroutine_create(function(A)
    ensure_equals("A", A, "A")

    local inner = coroutine_create(function(B)
      ensure_equals("B", B, "B")

      ensure_equals(
          "F",
          eat_true(
              pcall(function(C)
                ensure_equals("C", C, "C")

                ensure_equals("E", coro.yield_outer("D"), "E")

                return "F"
              end, "C")
            ), "F"
        )

      return "G"
    end)

    ensure_equals("G", eat_true(coro.resume_inner(inner, "B")), "G")
    ensure_equals("inner dead", coroutine_status(inner), "dead")

    return "H"
  end)

  ensure_equals("H", eat_true_tag(coroutine_resume(outer, "A")), "D")
  ensure_equals("H", eat_true(coroutine_resume(outer, "E")), "H")
  ensure_equals("outer dead", coroutine_status(outer), "dead")

end)

--------------------------------------------------------------------------------

--[[
    Mesage passing scheme for basic test:

    main        outer       inner1        inner2
      |           .           .             .
      A--------c->*           .             .
      |           |           .             .
      *<=g========B           .             .
      |           |           .             .
      C========g=>*           .             .
      |           |           .             .
      *<-l--------D           .             .
      |           |           .             .
      E--------l->*           .             .
      |           |           .             .
      |           F--------c->*             .
      |           |           |             .
      *<=g========o===========G             .
      |           |           |             .
      H===========o========g=>*             .
      |           |           |             .
      |           <-l---------I             .
      |           |           |             .
      |           J--------l->*             .
      |           |           |             .
      |           |           K----------c->*
      |           |           |             |
      *<=g========o===========o=============L
      |           |           |             |
      M===========o===========o==========g=>*
      |           |           |             |
      |           |           *<-l----------N
      |           |           |             |
      |           |           O----------l->*
      |           |           |             |
      |           |           *<-r----------P
      |           |           |             .
      |           *<-r--------Q             .
      |           |           .             .
      *<-r--------R           .             .
      |           .           .             .

--]]

test "basic" (function()
  local cat, concat = make_concatter()

  do
    local outer = coroutine_create(function(A)
      cat(A) --> A

      cat(coro.yield_outer("B")) --> C

      -- Outer coroutines may do inner yields
      -- (in case they're held by inner corouines).
      cat(coroutine_yield("D")) --> E

      local inner1 = coroutine_create(function(F)
        cat(F) --> F

        cat(coro.yield_outer("G")) --> H
        cat(coroutine_yield("I")) --> J

        local inner2 = coroutine_create(function(K)
          cat(K)

          cat(coro.yield_outer("L")) --> M
          cat(coroutine_yield("N")) --> O

          return "P"
        end)

        cat(eat_true(coro.resume_inner(inner2, "K"))) --> N
        cat(eat_true(coro.resume_inner(inner2, "O"))) --> P

        assert(coroutine_status(inner2) == "dead")

        return "Q"
      end)

      cat(eat_true(coro.resume_inner(inner1, "F"))) --> I
      cat(eat_true(coro.resume_inner(inner1, "J"))) --> Q

      assert(coroutine_status(inner1) == "dead")

      return "R"
    end)

    cat(eat_true_tag(coroutine_resume(outer, "A"))) --> B
    cat(eat_true(coroutine_resume(outer, "C"))) --> D
    cat(eat_true_tag(coroutine_resume(outer, "E"))) --> G
    cat(eat_true_tag(coroutine_resume(outer, "H"))) --> L
    cat(eat_true(coroutine_resume(outer, "M"))) --> R

    assert(coroutine_status(outer) == "dead")
  end

  assert(concat() == "ABCDEFGHIJKLMNOPQR")
end)

--------------------------------------------------------------------------------

-- NOTE: Tests below check all these functions in conjunction,
--       so we're simply declaring them here as tested.
--       When adding function to this list, make sure it has tests first.

test:tests_for 'eat_tag'
               'is_outer_yield_tag'

--------------------------------------------------------------------------------

test:test "eat_tag-is_outer_yield_tag-not-tag" (function()
  ensure_equals("that is not the tag", coro.is_outer_yield_tag(42), false)
  ensure_tequals(
      "do not eat non-tag true",
      { coro.eat_tag(true, 42) },
      { true, 42 }
    )
  ensure_tequals(
      "do not eat non-tag false",
      { coro.eat_tag(false, 42) },
      { false, 42 }
    )
end)

test:test "eat_tag-is_outer_yield_tag-actual-tag" (function()
  local tag
  do
    local co = coroutine_create(function()
      coro.yield_outer()
    end)

    local _
    _, tag = assert(coroutine.resume(co))
  end

  ensure_equals("that is the tag", coro.is_outer_yield_tag(tag), true)
  ensure_tequals(
      "eat tag true",
      { coro.eat_tag(true, tag, 42) },
      { true, 42 }
    )
  ensure_tequals(
      "eat tag false",
      { coro.eat_tag(false, tag, 42) },
      { false, 42 }
    )
end)

--------------------------------------------------------------------------------

assert(test:run())
