# Introduction

  * It seems that in the console executable, running locally, almost everything is supported (except `io.popen()` which is due to `generic` make target used; it is fine, since it likely would not work on Windows anyway). The information on this page is more related to the sandboxed GUI case.
  * Core Lua Library functionality, not mentioned here, should work just fine.

# Stream IO

  * In native GUI apps using Lua it is common practice to overload `print()` to print to log (ActionScript's `trace()` or a hidden log sprite in GUI), and to disable `io.stdin`. Output streams `io.stdout` and `io.stderr` are to be redirected to log or disabled as well. It is fine to follow this practice.

# Modular sources and File IO

To allow comfortable reuse of existing Lua code with Lua Alchemy, we must support following functions:

  * `loadfile()`
  * `dofile()`
  * `require() and package.*` for Lua sources
  * `require() and package.*` for Lua C (or other language) shared library modules, compiled in Alchemy.

We should put "virtual file system" wrapper on the file (both code and data) access. VFS targets:

  * Files, bundled into the current SWF (read-only). Should be configurable from Lua, C and/or ActionScript so prefix could be removed to ease porting of existing sources:

```
	dofile("builtin://path/file.lua") 
	local file = assert(io.open("builtin://path/data.dat", "r"))
	AS3.io_set_default_prefix("builtin://path")
	dofile("file.lua") -- same file as above
```

> Default prefix setting should support all of available options. Note from the Lua point of view `AS3.io_set_default_prefix("path")` is conceptually the same as `os.exec("cd path")`.

  * Files, bundled into other SWFs (read-only; available SWFs added with special API function from Lua, C and/or ActionScript). **TODO:** Ensure that no AS3 SWF load specifics would inhibit this.

```
	 AS3.io_add_swf("swf-name", "URI")
	 dofile("swf://swf-name/path/file.lua") 
	 local file = assert(io.open("swf://swf-name/path/data.dat", "r"))
```

  * Files, located on the local Flash storage (read/write).

```
	 dofile("storage://path/file.lua")
	 local file = assert(io.open("storage://path/data.dat", "r+"))
```
> !**NOTE:** Loading code from local storage seems to be silly and insecure. Probably we should disable it.

  * Files, uploaded by user with open/save file dialog (read for open/write for save).

```
	 dofile("open://") -- A lua script runner
	 local read_file = assert(io.open("open://", "r"))
	 local write_file = assert(io.open("save://", "w"))
```

> !**NOTE:** **AG:** I do not like this filename-less notation much. Any ideas?

> !**TODO:** There could be problems with that save:// files would likely to allowed to save only once. So the actual save is to be done only when handle is closed.

  * Files, located in the file system (read/write within sandbox limits; no limits in console mode).

```
	 dofile("file:///Users/Me/myfile.lua")
	 local file = assert(io.open("C:\\Windows\\system32\\drivers\\etc\\hosts", "r+"))
```

## Lua Modules

> Lua's `require()` does not separate shared library modules from the plain Lua modules. See [docs](http://www.lua.org/manual/5.1/manual.html#pdf-require) on how it works. We should replace `package.loaders` contents with our functions which know about our VFS. Once we have that and have working `loadfile()`, all would have to do is implement `[http://www.lua.org/manual/5.1/manual.html#pdf-package.loadlib package.loadlib]` to load shared libraries -- this should be enough.

The above also affects these functions:

  * io.open()
  * io.input()
  * io.output()
  * io.tmpfile()
  * os.remove()
  * os.rename()

## Note on possible implementation

To allow reading of "weird" files, not available by `supplyFile()`, we may use `funopen()` approach to get `FILE*` pointer on `ByteArray`.

Code from libpng sample in Alchemy:
```
/* Does a FILE * read against a ByteArray */
int readba(void *cookie, char *dst, int size)
{
  return AS3_ByteArray_readBytes(dst, (AS3_Val)cookie, size);
}

/* Does a FILE * write against a ByteArray */
int writeba(void *cookie, const char *src, int size)
{
  return AS3_ByteArray_writeBytes((AS3_Val)cookie, (char *)src, size);
}

/* Does a FILE * lseek against a ByteArray */
fpos_t seekba(void *cookie, fpos_t offs, int whence)
{
  return AS3_ByteArray_seek((AS3_Val)cookie, offs, whence);
}

/* Does a FILE * close against a ByteArray */
int closeba(void * cookie)
{
  AS3_Val zero = AS3_Int(0);

  /* just reset the position */
  AS3_SetS((AS3_Val)cookie, "position", zero);
  AS3_Release(zero);
  return 0;
}

// open up a file that fwds operations to the ByteArray
FILE *f = funopen((void *)dest, readba, writeba, seekba, closeba);

```

# Supported System Functions

We should check that these functions work correctly in sandboxed mode:

  * os.tmpname()
  * os.clock() -- precision
  * os.getenv() -- especially in the sandbox mode (it should be OK if it returns empty environment)
  * os.setlocale()

# Unsupported System Functions

Functions listed below probably make sense only in console mode (and they **do** and would work there). We should check that they do not break anything in sandbox, and leave them be.

  * os.execute()
  * os.exit()
  * io.popen()