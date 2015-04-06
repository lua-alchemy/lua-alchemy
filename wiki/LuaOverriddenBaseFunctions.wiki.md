Lua Alchemy overrides some of base Lua functions to make them work in the Alchemy environment.

This functionality is optional. See UsingRawLuaAlchemy. Also note that you're free to override these functions again by yourself as you see fit.

See also CoreLuaLibraries for future plans.

### loadfile(filename)

The `loadfile()` function is overridden to allow loading from Lua files, embedded into current .swf file.

Support is planned for loading from local filesystem for trusted .swfs (TODO: `flyield()` issue blocks this).
To use this feature, you need to declare your .swf as a trusted one. See scripts `'etc/osx-rapid-*.sh'` for a hint on how to do this. TODO: Document these scripts.

Note that original Lua `loadfile()` supports call **without arguments**, triggering read from `stdin`. Currently this feature is **not supported**.

Lua Alchemy `loadfile()` works as follows:

  1. First it checks if filename contains protocol prefix (in form `^[a-z_-]+://`).
  1. If there are no prefix, current Lua Alchemy virtual filesystem root is appended to the filename, and resulting string is checked again for prefix.
  1. If effective prefix is `builtin://`, file is loaded from files, added in AS3 with `supplyFile()` call.
  1. Otherwise file is loaded with AS3 `URLLoader`. (**NOTE:** Currently this step always fails due to `flyield()` issue.)
  1. If file load fails and effective prefix was not `builtin://` and original filename did not contained prefix, it is attempted to load the file from the path `"builtin://"..filename`. This is needed to speed up end-user code development by allowing him to drop in embedded Lua code changes on the filesystem without the need to recompile .swf.

The virtual filesystem root is expected to be set in global Lua variable `_LUA_ALCHEMY_FILESYSTEM_ROOT`. If it is `nil`, then virtual filesystem root is assumed to be `builtin://`.

See also AutoAssets and **"Modular sources and File IO"** section in CoreLuaLibraries.

### dofile(filename)

The `dofile()` function simply calls `loadfile()`.

### print(...)

Lua `print()` is redirected to `as3.trace()`