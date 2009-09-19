-- table.lua: - various utilities for managing lua tables - used in tests
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

local function gen_random_dataset(num, nesting, visited)
  nesting = nesting or 1
  visited = visited or {}
  num = num or math.random(0, 10)
  local gen_str = function()
    local len = math.random(1, 64)
    local t = {}
    for i = 1, len do
      t[i] = string.char(math.random(0, 255))
    end
    return table.concat(t)
  end
  local gen_bool = function() return math.random() >= 0.5 end
  local gen_udata = function() return newproxy() end
  local gen_func = function() return function() end end
  local gen_thread = function() return coroutine.create(function() end) end
  local gen_nil = function() return nil end
  local gen_visited_link = function()
    if #visited > 1 then
      return visited[math.random(1, #visited)]
    else
      return gen_str()
    end
  end
  local generators =
  {
    gen_bool;
    gen_bool;
    gen_bool;
    function() return math.random(-10,10) end;
    gen_str;
    gen_str;
    gen_str;
   --[[ gen_thread;
    gen_thread;
    gen_func;
    gen_func;
    gen_udata;
    gen_udata;--]]
    gen_visited_link;
    function()
      if nesting >= 10 then
        return nil
      end
      local t = {}
      visited[#visited + 1] = t
      local n = math.random(0, 10 - nesting)
      for i = 1, n do
        local k = gen_random_dataset(1, nesting + 1,visited)
        if k == nil then
          k = "(nil)"

        end
        t[ k ] = gen_random_dataset(1,nesting + 1,visited)
      end
      return t
    end
  }
  local t = {}
  visited[#visited + 1] = t
  for i = 1, num do
    local n = math.random(1, #generators)
    t[i] = generators[n]()
  end
  return unpack(t, 1, num)
end

local mutate
do
  local impl
  impl = function(t,visited,vis)
    local mutated = false
    visited = visited or {}
    vis=vis or {}
    if type(t) == table then
      if not vis[t] then
	visited[#visited + 1] = t
	vis[t] = true
      end
      local n = math.random(0, 2)
      if n == 0 then
	for k, v in pairs(t) do
	  t[k] = nil
	  local v_1 = impl(v, visited, vis)
	  local k_1 = impl(k, visited, vis)
	  if k_1 ~= k or v_1 ~= v then
	    mutated = true
	  end
	  k = k_1
	  v = v_1
	end
      elseif n == 1 then
	local n = math.random(1, #visited)
	local t1 = visited[n]
	if t1 ~= t then
	  mutated = true
	end
      else
	local t1 = gen_random_dataset()
	if t1 ~= t then
	  mutated = true
	end
	t = t1
      end
    else
      local t1 = gen_random_dataset()
      if t1 ~= t then
	mutated = true
      end
      t = t1
    end
    return t, mutated
  end

  mutate = function(t)
    local r, mutated = impl(t)
    return mutated, r
  end
end

return
{
  gen_random_dataset = gen_random_dataset;
  mutate = mutate;
}
