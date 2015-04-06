# Initial file releases

Mentioned items are more like tangents to the main project, but they may help to attract some attention.

## 1. Alchemy's lua and luac executables for OS X and Windows (and maybe Linux)

So interested people would be able to play with the tech without
the need to setup whole build chain.

**Problem**:

Alchemy's "executables" aren't really executables, they are swfs in a shell script with the following to execute them:

` #!/Users/universalmind/code/alchemy-darwin-v0.4a/bin/swfbridge `

**TODO:** Looks like we would have to redistribute unknown amounts of Alchemy and Flex. This needs some research. It may be easier to provide detailed step-by-step build instructions.

**TODO:** Lua's `make generic` omits some useful features like libreadline. We should try to tune our build to include them.

**UPDATE:** From the Adobe Flex FAQ:

**Q:** Can I include the Free Adobe Flex 3 SDK as part of my own application?

**A:** Yes. The Free Adobe Flex 3 SDK provides a Java API that allows you to call the compiler directly from your code instead of needing to call the command-line tools. You may redistribute the Free Adobe Flex SDK with your application provided you have signed a free redistribution agreement (expected in March 2008).

## 2. [Official Lua Test Suite](http://www.inf.puc-rio.br/~roberto/lua/lua5.1-tests.tar.gz) run results

As in [this](http://groups.google.com/group/lua-alchemy-dev/msg/996ec28605346254) post. On featured wiki page.

**TODO:** Do not forget to set environment variables according to the README file.

**TODO:** Post a **diff** between the native and swf runs along with analysis.

**TODO:** Also run with intrusive C tests ("testC" option, see README). Add some 'test' and 'test-more' targets to our makefile.

## 3. Benchmarks for the relevant Lua code

Use code from [benchmarks/](http://github.com/lua-alchemy/lua-alchemy/tree/master/benchmark) directory.

Publish both code and the results so everyone would be able to reproduce them.

## 4. Lua console GUI emulation

This probably it is most spectacular thing we're able to pull out without
implementing Lua to ActionScript bridge. Simply rewrite lua.c to be usable from AS side; no fancy tricks on this step. It is a nice demo anyway, and mentioned bridge may be integrated into it later.