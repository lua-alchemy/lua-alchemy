-- Create a dynamic AS3 object with some methods that increment values

-- Override print so results can be displayed in canvas
print = as3.makeprinter(output)

-- Increment function
local inc = function(self, n)
  self.i = self.i + (n or 1)
end

-- Get function
local get = function(self)
 return self.i
end

-- One way to create a Lua "class" to increment and get
local make_counter = function()
 return
 {
   inc = inc;
   get = get;
   i = 0;
 }
end

-- Create instances of Lua counter class
local t1 = make_counter()
local t2 = make_counter()

-- Increment the Lua counter class
t1:inc()
t1:inc()
t2:inc(5)

print ("t1:", t1:get(), "t2:", t2:get())

-- Function to create AS3 counter object that wraps Lua counter
local counter_to_as = function(t)
   local obj = as3.class.Object.new()
   obj.inc = function(...) t:inc(...) end
   obj.get = function() return t:get() end
   return obj
end

-- Create two AS3 counters
local as_counter1 = counter_to_as(t1)
local as_counter2 = counter_to_as(t2)

-- Incurement the AS3 counters
as_counter1.inc()
as_counter2.inc(10)

print ("t1:", t1:get(), "t2:", t2:get())

print ("as_counter1:", as3.tolua(as_counter1.get()), "as_counter2:", as3.tolua(as_counter2.get()))
