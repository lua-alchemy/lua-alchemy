See also: [Issues](http://code.google.com/p/lua-alchemy/issues/list)

**TODO:** Move this to [Issues](http://code.google.com/p/lua-alchemy/issues/list)

# Unsorted

  * Add this to the VFS proposal:
> > `supplyFile(path:String, data:ByteArray)`: This method allows you to provide a file at a specified path for the C code. This is useful if your C code expects a configuration file at a specific location that is not accessible to the runtime due to security restrictions. (Quote from [here](http://labs.adobe.com/wiki/index.php/Alchemy:Documentation:Developing_with_Alchemy:AS3_API).)
  * Use this for io?! Hide that sprite and show it on ctrl+l as a console!
> > `setSprite(sprite:Sprite):void`: This method takes a sprite to use as the "command line" for Alchemy. It will create a new TextField on this Sprite and channel output from STDOUT, STDERR to it. It will also accept input and route to STDIN. This is not required to be set, but it will be by default. (Quote from [here](http://labs.adobe.com/wiki/index.php/Alchemy:Documentation:Developing_with_Alchemy:AS3_API).)

# Design

  * TypeConversions: Describe type conversions as a two tables: Lua->ActionScript and ActionScript->Lua
  * FeatureWishList: Add an initial prototype of UI construction library (MXML analogue in Lua).

# InitialFileReleases

  * GUI Lua console emulator, embeddable in browser. (Goes to demo/ directory.) Try setSprite() stuff on lua.c code as a simplest solution. Compile with at least libreadline turned on!
  * Decide on the distribution of the Lua console executable, compiled with Alchemy. Probably it does not worth it.
  * Add official test suite run targets (plain and testC mode) to the makefiles. Publish analysis of diffs of the test runs for native and Alchemy Lua builds. (along with results and instructions to reproduce them.)
  * Add benchmark runner script (as a makefile target?). Publish analysis, results and steps to reproduce for native vs. Alchemy Lua builds.
  * Run official test suite in sandboxed mode (add to Unit Tests).

# Implementation

  * Roll out a Makefile or ant file to be able to build without Flex Builder.
  * CoreLuaLibraries: Implement code module support and file IO support. (Waits for VFS proposal decision.)
  * CoreLuaLibraries: Check that Supported System Functions work correctly in sandboxed mode
  * CoreLuaLibraries: Check that Unsupported System Functions do not break anything in sandboxed mode

# Extra features

  * FeatureWishList: Implement Flex data bindings support.
  * FeatureWishList: Implement Lua compiler removal feature (leaving VM to execute bytecode).
  * KnownProblems: Investigate Alchemy + llvm-lua feature further.

# Organizational

  * Ensure everywhere in code and in docs project is named "Lua Alchemy" if spaces are fit or "lua-alchemy" (with dash) if not. The "lua\_alchemy" is the last resort if dash is not available.