-- tdeepequals.lua: Test arbitrary lua tables for equality.
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

-- Tests arbitrary lua tables for equality.
-- Functions, threads, etc. are supported
-- Metatables are ignored.
-- The tmore function introduces linear ordering in the set of all lua tables.
-- That is, for two arbitrary tables we can define an ordering
--     '>=' : t1>=t2 <=> tmore(t1,t2)>=0 ,
-- the following statements are hold for all tables a, b and c:
-- If a ≤ b and b ≤ a then a = b (antisymmetry); (if tmore(a,b)=0 then a=b)
-- If a ≤ b and b ≤ c then a ≤ c (transitivity);
-- (tmore(a,b)*tmore(b,c)*tmore(c,a)<=0)
-- a ≤ b or b ≤ a (totality).

local pairs, type, ipairs, tostring = pairs, type, ipairs, tostring
local table_concat, table_sort = table.concat, table.sort
local string_format, string_match = string.format, string.match

local tdeepequals
local tmore

do
  local p_table -- table, containing hashes of pointer-like data:
                --functions, threads, userdata

  ------------------------------------------------------------
  --------------------  UTILITY FUNCTIONS  -------------------
  ------------------------------------------------------------

  --1.make a duplicate(copy) of a table
  local  table_dup = function(t)
    assert(type(t) == "table")
    local td = {}
    for k,v in pairs(t) do
      td[k] = v
    end
    return td
  end

  --2.Generic more(for strings and numbers)
  local more = function(t1, t2)
    if t1 > t2 then
      return 1
    elseif t1 < t2 then
      return -1
    else
      return 0
    end
  end

  --3.Boolean more(for strings and numbers)
  local bool_more = function(t1, t2)
    if not t1 and t2 then
      return -1
    end
    if ((not t1) and (not t2)) or (t1 and t2) then
      return 0
    end
    return 1
  end

  --4.More for threads, functions and userdata
  --  (using hash table p_table) and also nil
  local p_more = function(t1, t2)
    if not t1 and not t2 then
      return 0
    end
    if not t1 then
      return -1
    end
    if not t2 then
      return 1
    end
    if not p_table[t1] then
      p_table.n = p_table.n + 1
      p_table[t1] = p_table.n
    end
    if not p_table[t2] then
      p_table.n = p_table.n + 1
      p_table[t2] = p_table.n
    end
    return p_table[t1] - p_table[t2]
  end

  --5.Compare (less) utility for boolean
  local bool_comp = function(t1, t2)
    return not t1 and  t2
  end

  --6.Compare (less) utility for userdata, threads, functions
  local p_comp = function(t1, t2)
    return p_more(t1, t2) < 0
  end

  --7. Compare (less) utility generator for key-value pairs,
  --   where key is a table.

  local table_comp = function(visited)
    return function(t1, t2)
      local vis1 = table_dup(visited)
      local vis2 = table_dup(visited)
      local m = tmore(t1[1], t2[1], vis1, vis2)
      if m == 0 then
        m = tmore(t1[2], t2[2], vis1, vis2)
      end
      return m < 0
    end
  end

  --8. Generic compare for everything except tables
  local nontable_comp = function(t1,t2)
    return tmore(t1, t2) < 0
  end

  ------------------------------------------------------------
  ------------------------  MAIN WORK  -----------------------
  ------------------------------------------------------------

  --for a given table returns a number of sorted arrays -
  --ikeys contains integer keys etc.
  --tkeys contains sorted {key,value} pairs in which key is a table
  --visited is a hash of already visited tables - used to cope with
  --recursive tables and tables having shared sub_tables:
  --e.g. 1 (recursive): local t = {} t[t] = 1
  --e.g. 2 (shared)   : local t1 = {} local t = {t1,t1}
  local analyze = function(t)
    local tkeys = {}
    local keys = {}
    for k, v in pairs(t) do
      local k_type = type(k)
      if k_type == "table" then
        local ind = #tkeys + 1
        tkeys[ind] = {}
        tkeys[ind][1] = k
        tkeys[ind][2] = t[k]
      else
        keys[#keys + 1] = k
      end
    end
    table_sort(keys, nontable_comp)
    return keys, tkeys
  end

  -- compares two generic pieces of lua data - first and second
  -- vis1 and vis2 are hashes of visited tables for first and second
  tmore = function (first, second, vis1, vis2)
    local type1, type2 = type(first), type(second)
    if type1 ~= type2 then
      return more(type1, type2)
    else
      if type1 == "number" or type1 == "string" then
        return more(first, second)
      elseif type1 == "boolean" then
        return bool_more(first, second)
      elseif type1 == "table" then
        if vis1[first] and vis2[second] then
          return more(vis1[first], vis2[second])
        end
        if vis1[first] then
          return 1
        end
        if vis2[second] then
          return -1
        end
        vis1.n = vis1.n + 1
        vis1[first] = vis1.n
        vis2.n=vis2.n + 1
        vis2[second] = vis2.n
        local keys1, tkeys1 = analyze(first)
        local keys2, tkeys2 = analyze(second)
        local i
        local m
        -- nontable keys
        i = 1
        if keys1 or keys2 then
          while i <= #keys1 and i <= #keys2 do
            m = tmore(keys1[i], keys2[i])
            if m ~= 0 then
              return m
            end
            m = tmore(first[keys1[i]], second[keys2[i]], vis1, vis2)
            if m ~= 0 then
              return m
            end
            i = i + 1
          end
          m = more(#keys1 - i, #keys2 - i)
          if m ~= 0 then
            return m
          end
        end
        -- table keys
        if tkeys1 or tkeys2 then
          table_sort(tkeys1, table_comp(vis1));
          table_sort(tkeys2, table_comp(vis2));
          i = 1
          while i <= #tkeys1 and i <= #tkeys2 do
            local m = tmore(tkeys1[i][1], tkeys2[i][1], vis1, vis2)
            if m ~= 0 then
              return m
            end
            m = tmore(tkeys1[i][2], tkeys2[i][2], vis1, vis2)
            if m ~= 0 then
              return m
            end
            i = i + 1
          end
          m = more(#tkeys1 - i,#tkeys2 - i)
          if m ~= 0 then
            return m
          end
        end
        return 0
      else -- userdata, thread, function
        return p_more(first,second)
      end
    end
  end

  tdeepequals = function(t1, t2)
    p_table = {n = 0}
    local r = tmore(t1, t2, {n = 0}, {n = 0})
    p_table = nil
    return r == 0
  end
end

return
{
  tdeepequals = tdeepequals;
  tmore = tmore;
}
