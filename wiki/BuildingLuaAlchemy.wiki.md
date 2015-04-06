Note that you do not need to build Lua Alchemy to use it — you may just get a pre-build SWC from [Downloads](http://code.google.com/p/lua-alchemy/downloads/list).

But if you want to contribute something or just to play around with sources, you'll have to be able to build Lua Alchemy from scratch.

### Toolchain

To be able to build Lua Alchemy, you'll need:

  * make
  * ant
  * Recent Adobe Flex SDK: http://opensource.adobe.com/wiki/display/flexsdk/Setup
  * Recent Adobe Alchemy SDK: http://labs.adobe.com/wiki/index.php/Alchemy:Documentation:Getting_Started

Toolchain installation on Windows is described here: SetupFlexSdkAlchemyOnWindows. On other platforms (Linux and OS X) it is pretty straightforward.

### Building

Building is straightforward.

```
$ alc-on
$ cd path/lua-alchemy/
$ make
```

### Troubleshooting

  * Ensure that you have run alc-on, and did not run it twice.
  * Open a fresh terminal and build from there if strange build issues arise.
  * If you experience ant errors, try adding this line to your ~/.bashrc (don't forget to re-open your terminal session afterwards):
```
export ANT_OPTS="-Xms768m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=256m"
```
  * On Windows, make sure that your user name does contain only Latin characters.