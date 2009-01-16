-- Return a bunch of values from Lua, which come back as a Stack

return
  true,
  "Hello from Lua",
  42,
  5.6+13,
  math.pi,
  as3.class.String.new("AS3 string"),
  as3.tolua(as3.class.Number.new(128)) + 2

--[[
Note that the String was not converted to a Lua type and the Number was
Calling as3.tolua() was not necessary for the String since no Lua operation
was performed on that value.  The Number needed conversion because of
the addition operator (which wouldn't have worked if it was still an
AS3 object)
--]]
