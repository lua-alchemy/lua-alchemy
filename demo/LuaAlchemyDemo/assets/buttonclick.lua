local vbox = as3.class.mx.containers.VBox.new()
local label = as3.class.mx.controls.Label.new()
local input = as3.class.mx.controls.TextInput.new()
local button = as3.class.mx.controls.Button.new()

label.text = "Name:"

button.label = "Say Hello"
button.addEventListener(as3.class.flash.events.MouseEvent.CLICK,
  function (e)
      as3.class.mx.controls.Alert.show("Hello " .. as3.tolua(input.text), as3.type(e))
  end, false, 0, true) -- set useWeakReference=true so listener doesn't keep button reference

vbox.addChild(label)
vbox.addChild(input)
vbox.addChild(button)

canvas.addChild(vbox)
