Lua Alchemy is no longer supported
----------------------------------

Dear Lua Alchemy users,

Thank you for your support in all these years! As you know, Lua Alchemy is based on the old Adobe Alchemy technology, which is no longer supported by Adobe. 

If you need Lua support in the browser, take a look at [lua.vm.js](https://kripken.github.io/lua.vm.js/lua.vm.js.html), [lua5.1.js](https://github.com/logiceditor-com/lua5.1.js/), [Moonshine](http://moonshinejs.org/) and other JS-based implementations. They are the future.

If you really need to use Lua in Adobe Flash, you may want to find someone to sponsor Lua Alchemy port to [FlashCC](http://www.adobe.com/devnet-docs/flascc/README.html), which is the current supported version of Adobe Alchemy. [My company](http://logiceditor.com) engineers are available to do the actual work, but, alas, I do not have resources to do this as an unpaid personal hobby project myself. If you're interested, please contact us at lua-alchemy@logiceditor.com.

If you need commercial support for the current Lua Alchemy, write at the same address.

You can get free support from the community at the [Lua Alchemy mailing list](https://groups.google.com/forum/#!forum/lua-alchemy-dev) and on [StackOverflow](http://stackoverflow.com/search?q=lua-alchemy).

-- Alexander Gladysh, the Lua Alchemy maintainer.

Background
----------

Lua is a great dynamic programming language, Adobe Flash is a great
universal platform for applications and Adobe Alchemy is the tool to
bind them together.

The main webpage can be found here:
http://code.google.com/p/lua-alchemy/

Lua
---
Lua is a powerful, fast, light-weight, embeddable scripting language.

Lua combines simple procedural syntax with powerful data description
constructs based on associative arrays and extensible semantics. Lua
is dynamically typed, runs by interpreting bytecode for a register-based
virtual machine, and has automatic memory management with incremental
garbage collection, making it ideal for configuration, scripting, and
rapid prototyping.

-- http://lua.org/about.html

Adobe Flash
-----------

Adobe Flash (previously called "Macromedia Flash"') is a set of
multimedia software created by Macromedia and currently developed and
distributed by Adobe Systems. Since its introduction in 1996, Flash has
become a popular method for adding animation and interactivity to web
pages; Flash is commonly used to create animation, advertisements, and
various web page components, to integrate video into web pages, and more
recently, to develop rich Internet applications.

-- http://en.wikipedia.com/wiki/Flash

Adobe Alchemy
-------------

With Alchemy, Web application developers can now reuse hundreds of
millions of lines of existing open source C and C++ client or
server-side code on the Flash Platform. Alchemy brings the power of high
performance C and C++ libraries to Web applications with minimal
degradation on AVM2. The C/C++ code is compiled to ActionScript 3.0 as a
SWF or SWC that runs on Adobe Flash Player 10 or Adobe AIR 1.5.

-- http://labs.adobe.com/technologies/alchemy/

Motivation
----------

We need Lua Alchemy to...

  * ...To use *run-time dynamic* programming language (Lua) within
    the Flash framework.
  * ...To *reuse* existing Lua code for the Flash-based utilities
  * ...To get a *great cross-platform back-end* (Flash) for (simpler)
    Lua-based games
  * ...To have fun with *awesome* new technology :-)

File Manifest
-------------

    AUTHORS - Contact information for the authors of lua-alchemy
    BUGS - List of known issues
    COPYRIGHT - Copyright for the lua-alchemy project
    HISTORY - Project history log
    README - This file describing the project
    SPONSORS - The list if Lua Alchemy sponsors
    alchemy/ - Builds lua-alchemy.swc
    build/ - Build utility tools
    demo/ - Flash and Flex demos
    etc/ - Odds and ends of various usefulness
    test/ - Lua and ActionScript tests

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/lua-alchemy/lua-alchemy/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
