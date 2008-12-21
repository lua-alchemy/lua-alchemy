local box = as3.new("mx.containers::Canvas")

as3.set(box, "width", 20)
as3.set(box, "height", 20)
as3.set(box, "x", as3.get(canvas, "width") - 20)
as3.set(box, "y", as3.get(canvas, "height") - 20)
as3.call(box, "setStyle", "backgroundColor", "blue")

as3.call(canvas, "addChild", box)

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

_G.finalize_ = debug.setmetatable(newproxy(),
{
 __gc = function()
  as3.call(timer, "stop")
  timer = nil
 end
})