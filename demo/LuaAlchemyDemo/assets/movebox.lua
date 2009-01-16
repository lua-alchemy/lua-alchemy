-- Creates a 20x20 blue box and moves it around randomly

-- returns a random (x,y) location for the box within the canvas
function randomBoxLocation()
  return math.random(0, as3.tolua(canvas.width) - 20),
         math.random(0, as3.tolua(canvas.height) - 20)
end

-- Create the blue box and add it to the canvas
local box = as3.class.mx.containers.Canvas.new()
box.width = 20
box.height = 20
box.x, box.y = randomBoxLocation()
box.setStyle("backgroundColor", "blue")

canvas.addChild(box)

-- Create a move tween for the box
local move = as3.class.mx.effects.Move.new()
move.target = box
move.duration = 5000

-- function to handle moving the box on event calls
function movebox()
  move["end"]() -- end is a keyword in Lua so we can't call move.end()
  move.xTo, move.yTo = randomBoxLocation()
  move.play()
end

-- start moving the box at the beginning
movebox()

-- Create and start the timer to move the box every 5 seconds
local timer = as3.class.flash.utils.Timer.new(5000)
timer.addEventListener(as3.class.flash.events.TimerEvent.TIMER, movebox)
timer.start()

-- Stop the timer when LuaAlchemy#close() is called
as3.onclose(
  function(e)
    timer.stop()
    timer.removeEventListener(as3.class.flash.events.TimerEvent.TIMER, movebox)
    timer = nil
  end)
