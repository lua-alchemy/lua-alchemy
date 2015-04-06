# Features

  * Create class of type X
  * Optionally define a variable name for the new element (unique ID used if not defined)
  * Optionally Set properties
  * Optionally Set styles
  * Optionally Define handlers for events
  * Optionally Define children for a container

# Notes

  * Code inside strings is not supported -- use functions
  * No "build-time" checks are done, it is assumed that programmer knows what he wrote.
  * As usual, user would have to manually link all used components to his swf file.
  * We may use different generators from ui definition -- generate Lua objects, generate AS3 objects, generate MXML.
  * In the event handler all named objects are available as `self` object fields. For example: `self.vBox`, `self.myName`.
  * `(mx.path:Class) "name" {...}` should also work
  * We could provide fake mxml namespace to join all subnamespaces of flash.mx (with hardcoded map of class name -> actual namespace in the back).

# Code Prototype

```
local mx = as3.ui(as3.class.mx.controls)
local ga4flash = as3.ui(as3.class.com.google.analytics.components)

local data = mx:VBox "vBox" 
{
   -- Note you may use as3.class.flash.events.MouseEvent.CLICK directly 
   -- you just have to put it to square brackets to prevent syntax errors
   mx:alias("CLICK", as3.class.flash.events.MouseEvent.CLICK);

   ga4flash:FlexTracker "tracker"
   {
     account="UA-111-222";
     visualDebug=true;
     mode="AS3";
   };

   percentWidth="100%";
   percentHeight="100%";
   styles = { color = "red" };
   mx:HBox 
   {
       percentWidth="100%";
       mx:Label { text="Name:" };
       mx:TextInput "myName" { percentWidth="100%" };
   };
   mx:Button 
   {
       text="Say Hello";
       events=
       {
           -- Note self is a top-level vBox object
           CLICK = function(self, e) 
              as3.class.mx.controls.alert("Hello" .. as3.tolua(self.myName.text)) 
           end 
       };
   };
}

local as3_object = as3.uitoas3(data)

canvas.addChld(as3_object)
```

# API

## as3.`*`

  * as3.ui(classpath) : ui\_builder
  * as3.uiloadfile(filename) : ui\_data -- for code inside a file, mx builder is a global variable, as3.ui is also available to declare other builders as needed
  * as3.uiloadstring(code) : ui\_data -- same as as3.uiloadfile, but works with string
  * as3.uitoas3(ui\_data) : object
  * as3.uitolua(ui\_data) : object
  * as3.uitomxml(ui\_data) : string

## UI Builder Object

  * **TODO**

# Object Generation Pseudocode

TODO: Describe it with words instead!

```
local ui_builder = as3.ui(path)
local data = ui_builder:ClassName "id"
{
  property = value;
  styles = { name = value };
  events =
  {
    code = event_handler;
  }
}
```

Leads to

```
  local obj = as3.new(ui_builder.path, ClassName) -- handles aliases
  obj.property = value
  obj.setStyle(name, value)
  obj.addEventListener(code, impl.wrap_event_listener(event_handler))
  impl.register_named_object(obj, id)
```

  * Chidren are attached to parents with addChild().

# TODO

  * Describe UI Builder Object
  * Document API better
  * Write generated code for the code prototype (plain Lua Alchemy analogue, Lua Alchemy AS3 object  analogue and MXML text)