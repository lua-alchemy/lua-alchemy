-- Provides
--   as3.toobject()
--   as3.toarray()
--   as3.args_toarray()

do
  local function impl(t, visited) -- TODO: Must not crash. Return nil, error
    if type(t) ~= "table" then
      return t -- TODO: as3.toas3(t)?
    end

    local o = as3.new2(nil, "Object")
    for k, v in pairs(t) do -- TODO: Slow. Think out some batching?
      local tk = type(k)
      if tk ~= "string" then
        -- Intentionally not relying on __tostring() metamethods
        -- as there is no uniquiness guarantee.
        -- Intentionally not converting numeric keys to strings.
        error("unsupported key type")
      end

      assert(visited[v] == nil, "recursion detected")
      visited[v] = true

      o[tostring(k)] = impl(v, visited)

      visited[v] = nil
    end

    return o
  end

  -- Detects recursion (raises error)
  -- Does not support non-string keys (raises error)
  -- Numeric keys are *not* converted to strings
  as3.toobject = function(t)
    return impl(t, {})
  end
end

do
  local function impl(t, visited)
    if type(t) ~= "table" then
      return t -- TODO: as3.toas3(t)?
    end

    local a = as3.new2(nil, "Array")
    for _, v in ipairs(t) do -- TODO: Slow. Think out some batching?
      assert(visited[v] == nil, "recursion detected")
      visited[v] = true

      a.push(impl(v, visited))

      visited[v] = nil
    end

    return a
  end

  -- Detects recursion (raises error)
  -- Works with array part of table (as per ipairs() definition)
  -- Converts 1-based Lua to 0-based ActionScript
  as3.toarray = function(t)
    return impl(t, {})
  end
end

do
  -- Preserves embedded nils
  -- TODO: Document and test this!
  as3.argstoarray = function(...)
    local a = as3.new2(nil, "Array")
    local n = select("#", ...)
    for i = 1, n do
      a.push(as3.toarray( (select(i, ...)) ))
    end
    return a
  end
end

