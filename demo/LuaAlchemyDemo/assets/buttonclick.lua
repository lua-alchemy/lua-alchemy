local alertClass = as3.class("mx.controls::Alert")
local vbox = as3.new("mx.containers::VBox")
local label = as3.new("mx.controls::Label")
local input = as3.new("mx.controls::TextInput")
local button = as3.new("mx.controls::Button")

as3.set(label, "text", "Name:")

as3.set(button, "label", "Say Hello");
as3.call(button, "addEventListener", "click",
  function (e)
      as3.call(alertClass, "show", "Hello " .. as3.get(input, "text"), as3.type(e))
  end)

as3.call(vbox, "addChild", label)
as3.call(vbox, "addChild", input)
as3.call(vbox, "addChild", button)

as3.call(canvas, "addChild", vbox)