-- Count from 1 to a really big number, incrementing a label and yielding
-- to Flash between each and allowing pause

-- TODO flyield doesn't work as expected; flash times out and UI doesn't update

-- Create controls
local vbox = as3.class.mx.containers.VBox.new()
local label = as3.class.mx.controls.Label.new()
local button = as3.class.mx.controls.Button.new()

local pause = false

-- Setup pause button
button.label = "Pause"
pause_count = as3.toas3(
  function (e)
      pause = not pause
  end)
button.addEventListener(as3.class.flash.events.MouseEvent.CLICK, pause_count)

-- Add controls to canvas
vbox.addChild(label)
vbox.addChild(input)
vbox.addChild(button)
canvas.addChild(vbox)

-- Funciton to get the timer count for use in delays
function gettimer()
  return as3.tolua(as3.namespace.flash.utils.getTimer())
end

-- Function to delay X msec calling flyield between each msec
function delay(msec)
  local start = gettimer()
  repeat
    as3.flyield()
  until (gettimer() - start) >= msec
end

-- Cound from 1 to big number incrementing the counter every second
local count = 0
while true do
  delay(1000)

  if count > 1000000000 then
    count = 1
  end

  if not pause then
    count = count + 1
    label.text = count
    as3.trace("Count = " .. count)
  end
end

-- Remove the button event listener when Lua is closed
as3.onclose(
  function(e)
    button.removeEventListener(as3.class.flash.events.MouseEvent.CLICK, pause_count)
  end)
