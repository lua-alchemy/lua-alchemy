local vbox = as3.new("mx.containers::VBox")
local label = as3.new("mx.controls::Label")
local button = as3.new("mx.controls::Button")

local pause = false

as3.set(button, "label", "Pause");
as3.call(button, "addEventListener", "click",
  function (e)
      pause = not pause
  end)

as3.call(vbox, "addChild", label)
as3.call(vbox, "addChild", input)
as3.call(vbox, "addChild", button)
as3.call(canvas, "addChild", vbox)

function gettimer()
  return as3.toluatype(as3.namespacecall("flash.utils", "getTimer"))
end

function delay(msec)
  local start = gettimer()
  repeat
    as3.yield()
  until (gettimer() - start) >= msec
end

local count = 0
while true do
  delay(1000)
  
  if count > 1000000000 then
    count = 1
  end
  
  if not pause then
    count = count + 1
    as3.set(label, "text", count)
  end
end
