print = function(...) as3.set(output, "text", as3.get(output, "text") .. table.concat({...}, "\t") .. "\n") end
print("hello from Lua")

local alertClass = as3.class("mx.controls::Alert")
local vbox = as3.new("mx.containers::VBox")
local label = as3.new("mx.controls::Label")
local input = as3.new("mx.controls::TextInput")
local button = as3.new("mx.controls::Button")
local box = as3.new("mx.containers::Canvas")

as3.set(label, "text", "Name:")

as3.set(button, "label", "Say Hello");
as3.call(button, "addEventListener", "click",
  function (e)
      as3.call(alertClass, "show", "Hello " .. as3.get(input, "text"), as3.type(e))
  end)

as3.set(box, "width", 20)
as3.set(box, "height", 20)
as3.set(box, "x", as3.get(canvas, "width") - 20)
as3.set(box, "y", as3.get(canvas, "height") - 20)
as3.call(box, "setStyle", "backgroundColor", "blue")

as3.call(vbox, "addChild", label)
as3.call(vbox, "addChild", input)
as3.call(vbox, "addChild", button)

as3.call(canvas, "addChild", box)
as3.call(canvas, "addChild", vbox)

local move = as3.new("mx.effects::Move")
as3.set(move, "target", box)
as3.set(move, "duration", 5000)

function movebox()
  as3.call(move, "end")
  as3.set(move, "xTo", math.random(0, as3.get(canvas, "width") - 20))
  as3.set(move, "yTo", math.random(0, as3.get(canvas, "height") - 20))
  as3.call(move, "play")
end

movebox()

local timer = as3.new("flash.utils::Timer", 5000)
as3.call(timer, "addEventListener", "timer", movebox)
as3.call(timer, "start")

return
  true,
  "Hello from Lua",
  42,
  5.6+13,
  math.pi,
  as3.new("String", "AS3 string"),
  as3.new("Number", 128)