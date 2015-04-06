Note this page describes how to build vanilla Lua with Adobe Alchemy. It does not describe how to build our Lua Alchemy project. For that see BuildingLuaAlchemy.

# Required software

  * **OS X** with XCode or **Windows XP** with Cygwin. Should also work on **Linux**.

  * **[Adobe Flex3 SDK](http://www.adobe.com/products/flex/flexdownloads/index.html)**
> > Install it as described [here](http://opensource.adobe.com/wiki/display/flexsdk/Setup). Note links to detailed instructions at the bottom of the page.

  * **[Adobe Alchemy](http://labs.adobe.com/downloads/alchemy.html)**
> > Install it as described [here](http://labs.adobe.com/wiki/index.php/Alchemy:Documentation:Getting_Started).

  * **[Lua 5.1.4 Sources](http://www.lua.org/download.html)**
> > Simply unpack it somewhere.

# Build steps

1. Fire up you terminal (Cygwin shell if you're on Windows).

2. Change current directory to where you've unpacked Lua sources

```
    $ cd ~/lua-5.1.4 
```

3. Enable Alchemy tools

```
    $ alc-on 
```

4. Run make

```
    $ make generic 
```

5. That is it, Lua is compiled to Flash. Try it!
```
    $ cd src
    $ ./lua
```