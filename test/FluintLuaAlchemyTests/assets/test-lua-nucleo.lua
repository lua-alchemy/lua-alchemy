-- TODO: Generalize to as3.protectcallback()?
-- Protect callback return value follows lua.doString() convention.
local protectcallback = function(fn)
  return function(...)
    return as3.argstoarray(pcall(fn, ...))
  end
end

local run_tests = assert(
    assert(assert(loadfile('lua-nucleo/suite.lua'))()).run_tests
  )

-- TODO: Generalize!
-- TODO: It is bad that lua-nucleo solely resides in test/ directory.
--       However, do not use test/ for anything else -- or next rsync
--       would delete all extra files.
local all_tests = assert(assert(loadfile('test/all-tests.lua'))())

local tests = {}

local strict_mode = false -- TODO: Should be true. Whenever lua-nucleo is ready

-- TODO: Should work not on suite, but on test level.
for i = 1, #all_tests do
  local name = all_tests[i]
  -- TODO: Method name should be properly escaped!
  tests["testLuaNucleo" .. name] = protectcallback(function()
    local nok, errs = run_tests({ name }, strict_mode)
    -- TODO: Enhance error reporting
    assert(#errs == 0, "suite run failed, see logs")
    assert(nok > 0, "empty suite detected")
  end)
end

return as3.toobject(tests)
