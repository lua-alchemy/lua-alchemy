# Target platform

  * Lua 5.1.4, **unmodified**
  * Flash **10**
  * Flex is **not required** to use core functionality
  * **No paid tools** (e.g. FlexBuilder) should be required to use library, just the free **command-line SDK tools**.
  * Library must support on **OS X** 10.5+ and Windows **XP**. Support for **Linux** is likely. (Vista support is not guaranteed, but likely.)

# Implementation languages

  * **ActionScript** 3
  * ANSI **C** 89 (not C++, not C 99; preferably the "clean C" subset as in Lua -- to allow users to build library as C++ code)
  * **Lua** 5.1

# Core features

  * A framework to ease integration of Lua into ActionScript.
  * A layer for doing type conversions from Lua to ActionScript and vice versa. See TypeConversions.
  * As cross-boundary calls between ActionScript and C are slow (and C/Lua is fast), we must allow user to write his custom optimized C layer for his specific task, preferably using our low-level functionality like type-conversion.
  * For rapid development we support generic interoperability between Lua and ActionScript. This is the **main feature** of the Lua Alchemy library. See LuaToAs3Interface and As3ToLuaInterface.

# Extra features

  * Flex **data bindings** support is available as a feature, **optional** for end-user.
  * A library to construct UI as simple as it can be done with MXML. Could be easily done with Lua-based Data Description Language.
  * We may speed up our embedded Lua applications by removing compilation stage and bundling compiled Lua bytecode instead of sources. Also removing compilator itself from the library could save some space. Compilation in Lua is blazingly fast, but since we're running inside a VM... Anyway, this should be optional mode, not the default one for Lua Alchemy.

# Lua Support

  * Full support for the language.
  * As much of Core Lua Library functionality as possible is to be supported.
  * It seems that in the console executable, running locally, almost everything is supported (except `io.popen()` which is due to `generic` make target used; it is fine, since it likely would not work on Windows anyway).
  * For the info sandboxed GUI version, see CoreLuaLibraries.