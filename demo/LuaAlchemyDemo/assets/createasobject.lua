print = function(...)
 local t = {...}
 for k,v in pairs(t) do
   t[k] = tostring(v)
 end
 as3.set(output, "text", as3.get(output, "text") .. table.concat(t,"\t") .. "\n")
end

local inc = function(self, n)
  self.i = self.i + (n or 1)
end

local get = function(self)
 return self.i
end

local make_counter = function()
 return
 {
   inc = inc;
   get = get;
   i = 0;
 }
end

local t1 = make_counter()
local t2 = make_counter()

t1:inc(); t1:inc()

print ("t1:", t1:get(), "t2:", t2:get())

local counter_to_as = function(t)
   local obj = as3.new("Object")
   as3.set(obj, "inc", function(...) t:inc(...) end)
   as3.set(obj, "get", function() return t:get() end)
   return obj
end

local as_counter1 = counter_to_as(t1)
local as_counter2 = counter_to_as(t2)

as3.call(as_counter1, "inc")
as3.call(as_counter1, "inc")
as3.call(as_counter1, "inc")

-- TODO fix increment call with parameter
as3.call(as_counter2, "inc", 100)

print ("t1:", t1:get(), "t2:", t2:get())

-- TODO fix return of get
print ("as_counter1:",as3.type(as3.call(as_counter1, "get")))
