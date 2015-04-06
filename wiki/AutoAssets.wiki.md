Lua Alchemy provides auxilary tool to allow auto-embedding of files into .swf file. Such embedded files are made visible to Lua by the means of Alchemy's `supplyFile()` function.

# gen\_assets.sh

This file generates `LuaAssets.as` file, to embed all files in the given directory and subdirectories into an .swf.

## build.xml

The `gen_assets.sh` script is intended to be embedded into your `build.xml` script:

```
  <target name="generate.assets">
    <exec executable="${build.tools.dir}/gen_assets.sh" dir="${basedir}"
      input="${build.tools.dir}/LuaAssets.as.template"
      output="${basedir}/src/LuaAssets.as">
      <arg path="${basedir}/assets"/><!-- filesystem_root -->
      <arg value="LuaAssets"/><!-- assets_class_name -->
      <arg path="${basedir}/assets"/><!-- assets_prefix -->
      <arg value="mypackage"/><!-- package_name -->
    </exec>
  </target>
```

Make your compilation targets depend on `generate.assets`. See `demo/Rapid` for example.

## Usage

`$ gen_assets.sh filesystem_root assets_class_name assets_prefix [package_name] < in_file > out_file`

Template file must be piped to stdin, resulting file is piped to stdout.

Arguments:
  * `filesystem_root` -- A root directory where asset files are.
  * `assets_class_name` -- The name of assets class.
  * `assets_prefix` -- The prefix to the source filename for Embed directive. Usually the same as `filesystem_root`.
  * `package_name` -- The name of assets class package (optional, default is no package).

## LuaAssets.as.template

The `gen_assets.sh` script is intended to be used with `LuaAssets.as.template` file as input. You usually do not need to change anything in this file.

# LuaAssets.as

To expose your assets to Lua, you need to do as follows:

  1. Link newly generated `LuaAssets.as` file to your .swf.
  1. Call `LuaAssets.init()` to expose assets with Alchemy's `supplyFile()`. Note that current (0.5a) Alchemy implementation does not allow once supplied file to be overridden. It silently ignores all subsequent attempts to supply file with the same name again.
  1. Use `LuaAssets.filesystemRoot()` value to set `_LUA_ALCHEMY_FILESYSTEM_ROOT` Lua global variable. `LuaAlchemy` class sets this variable for you automatically. Note that while you may have as many `LuaAssets` classes as you want to, there is only one filesystem root variable.

Example initialization using `LuaAlchemy` class:

```
LuaAssets.init(LuaAlchemy.libInit);
var lua:LuaAlchemy = new LuaAlchemy(LuaAssets.filesystemRoot());
```

See `demo/Rapid` for more complete example.

## Methods

### init(libInitializer:`*`):void

Initializes `LuaAssets` data and exposes embedded files to given Alchemy's `CLib` initializer by calling `supplyFile()`.

### filesystemRoot():String

Returns virtual filesystem root. Note this value is hardcoded at the run time. This is a developer's convenience feature, not suitable for .swf end-users. It is intended to replace "process working directory" notion, missing in ActionScript.