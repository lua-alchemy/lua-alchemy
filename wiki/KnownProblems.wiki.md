**WARNING: Outdated content**

  * In Alchemy calls across C / ActionScript boundary are slow.

  * We've got Lua VM running inside ActionScript VM. This is also slow. It should be possible to convert Lua bytecode to AS bytecode directly with the help of [llvm-lua](http://code.google.com/p/llvm-lua/). But see [this post](http://marc.info/?l=lua-l&m=122847990506358&w=2): currently Alchemy uses outdated version of LLVM (2.1), which is incompatible with one in llvm-lua (2.4). We should try to encourage Alchemy developers to upgrade.

  * Strings in AS3 are UTF-16. Lua strings do perfectly fine with embedded zeroes, but Lua's string library does NOT support Unicode. Functions like string.length() would lie to you (tell you number of bytes instead of number of characters) etc -- the usual stuff.

> The common solution is to use a third party library to deal with Unicode.

> Please read this: http://lua-users.org/wiki/LuaUnicode

  * Arrays in Lua are one-based, and in ActionScript are zero-based. This would inevitably lead to problems.

  * ActionScript strings (and strings in Alchemy) may not contain embedded zeroes. (?!)