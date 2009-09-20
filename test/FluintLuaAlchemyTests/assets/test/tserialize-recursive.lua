-- tserialize-recursive.lua: recursive tests for tserialize
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

dofile('lua-nucleo/strict.lua')
dofile('lua-nucleo/import.lua')

local make_suite = select(1, ...)
assert(type(make_suite) == "function")

local check_ok = import 'test/lib/tserialize-test-utils.lua' { 'check_ok' }

--------------------------------------------------------------------------------

local test = make_suite("syntetic link tests")

--------------------------------------------------------------------------------

test "1" (function()
  local a={}
  local b={a}
  check_ok(a,b)
end)

test "2" (function()
  local a={}
  local b={a}
  local c={b}
  check_ok(a,b,c)
end)

test "3" (function()
  local a={1,2,3}
  local b={[true]=a}
  local c={[true]=a}
  check_ok(a,b,c)
end)

test "4" (function()
  local a={1,2,3}
  local b={a,a,a,a}
  local c={a}
  check_ok(a,b,c)
end)

test "5" (function()
  local t1={}
  local t2={}
  t1[t1]=t2
  local u={t1,t2}
  check_ok(u)
end)

test "6" (function()
  local t1={}
  local t2={}
  t1[1]=t2
  t2[1]=t1
  local u={t1,t2}
  check_ok(u)
end)

test "Complex recursive table" (function()
  local a={}
  a[a]=a a[{a,a}]={a,a}
  check_ok(a)
end)

test "Recursive table #1" (function()
  local a={}
  a[1]={a}
  check_ok(a)
end)

test "Recursive table #2" (function()
  local a={}
  a[1]={ {a} }
  check_ok(a)
end)

test "Recursive table #3" (function()
  local a={}
  a[1]={ a,{a} }
  check_ok(a)
end)

test "Recursive table #4" (function()
  local a={}
  a[{{a}}]={ a,{a} }
  a[a]=a
  check_ok(a)
end)

test "Very sophisticated recursive table #1" (function()
  local a={}
  a[a]=a a[{a,a}]={a,a} a[3]={ {a,{a,{a}},{[a]=a}} }
  check_ok(a)
end)

test "Very sophisticated recursive table #2" (function()
  local a={}
  local d={a}
  d[d]=1
  a[{d}]=2
  check_ok(a)
end)

test "Very sophisticated recursive table #3" (function()
  local a={}
  local b={}
  b[b]=b
  local c={}
  local d={[b]=c}
  a[d]=a
  b[true]=a
  c[a]="A"
  d[a]=true
  check_ok(c)
end)

test "recursion deep in keys" (function()
  local a={}
  local b={}
  local c={}
  a[a]=b
  b[b]=c
  c[c]=a
  a[{[{b,c}]=1}]=b
  b[{[{a,c}]=2}]=c
  c[{[{b,a}]=3}]=a
  check_ok(a)
end)

test "Autogen failed#1" (function()
  local c={}
  local b={[{c}]=1}
  c[3]=c
  b[b]=4
  check_ok(b)
end)

test "Autogen failed#2" (function()
  local a={}
  local b={[a]=1}
  local c={b, [a]=1}
  b[1]=c
  c[c]=1
  check_ok( b )
end)

test "Autogen failed#3" (function()
  local a={}
  local b={[true]=-5}
  local c={}
  local e={}
  local d={[true]=true,[{[-4]="l",[true]="h",l=b,[false]="l"}]="d"}
  local f= {}
  f[f]=f
  local g={[true]="e",k=d,[6]=false}
  d[false]=g
  d[{[true]=f,[a]=true,e="k",[-3]=true,[5]=false}]=true
  d["(nil)"]=g
  a["(nil)"]=a
  check_ok({
  [false]=c,
  [true]=d,
  [b]=-6,
  e={
    [false]=-5,
    [c]=false,
    [{[{[true]=false}]={[false]={[true]=false},d={}}}]=g,
    ["(nil)"]=-9,
    [e]={[{}]={},[true]=e,[a]=4, ["(nil)"]=false}
    },
  ["(nil)"]="i",
  [-4]={}
  })
end)

test "My1" (function()
  local a={1}
  local b={["a"]=17}
  a[a]=b
  local  c={2}
  c[b]=c
  b[c]=1
  check_ok(a)
end)

test "My2" (function()
  local a={1}
  local b={["a"]=17}
  b[a]=b
  local  c={[a]=1}
  c[b]=c
  b[c]=1
  check_ok(c)
end)

test "My3" (function()
  local v={}
  local a={}
  v[a]=1
  v[1]=a
  a[1]=v
  check_ok(v)
end)

test "My4" (function()
  local var4={}
  local var1={1,[{[{}]="l",var4=1}]=-10}
  var1[false]={["(nil)"]={[var4]="j",k="k",[{["(nil)"]=3,l="f"}]=false,n=false}}
  var1[true]=false
  var1["(nil)"]=8
  var1["j"]=var4
  var4["j"]=var1
  check_ok(var1)
end)

test "My5" (function()
  local a={}
  local b={1,a,[{a=1}]=-10}
  a[1]=b
  check_ok(b)
end)

--------------------------------------------------------------------------------

assert (test:run())
