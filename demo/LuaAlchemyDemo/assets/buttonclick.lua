-- Says hello to the name entered in the text box on a button click

-- Create the controls
local vbox = as3.class.mx.containers.VBox.new()
local label = as3.class.mx.controls.Label.new()
local input = as3.class.mx.controls.TextInput.new()
local button = as3.class.mx.controls.Button.new()

label.text = "Name:"
button.label = "Say Hello"

-- Add a button listener to pop up an alert saying hello
button.addEventListener(as3.class.flash.events.MouseEvent.CLICK,
  function (e)
      as3.class.mx.controls.Alert.show("Hello " .. as3.tolua(input.text), as3.type(e))
  end, false, 0, true) -- set useWeakReference=true so listener doesn't keep button reference

-- Add all the controls to the canvas in a VBox
vbox.addChild(label)
vbox.addChild(input)
vbox.addChild(button)

canvas.addChild(vbox)
