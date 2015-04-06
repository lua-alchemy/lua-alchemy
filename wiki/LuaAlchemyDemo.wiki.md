# Introduction
Lua Alchemy is a port of the Lua 5.1.4 programming language for ActionScript using Alchemy.

A live version of the demo can be found here: http://lua-alchemy.googlecode.com/svn/trunk/demo/index.html

# Known Issues
  * **Code Editor** - TextArea makes for a poor code editor. Behavior of copy/paste is erratic and you may loose line returns. You can load/save files and use a real code editor if needed.

  * **No stdio** - Lua calls to io.write() and print() don't have anywhere to go. The print() demo shows how to override print to go to the output canvas.

  * **Possible Memory Leaks** - Event listeners and timers made in Lua aren't cleaned up automatically. The "Moving Box" demo calls as3.onclose() to stop the timer. The "Button Click" demo uses a weak reference on the listener.

# Demo Interface
The Lua script has a "canvas" variable exported from the Flex application. This canvas is in the upper right of the demo application. You can manipulate this canvas just like any object using the as3 interface described in the link below.
Example
```
canvas.setStyle("backgroundColor", "red")
```

There is also an "output" variable exported from the Flex application. This is the TextArea in the lower right part of the demo and could be used to override the Lua print() function like this:
```
print = as3.makeprinter(output)
print("Hello World")
```

**Note:** Only classes that have been included in the demo can be created. At the very least all of mx.containers and mx.controls has been included along with all the top level and default classes all flash objects get.

# [Lua to ActionScript Interface](LuaToAs3Interface.md)