-- Save overridden functions just in case
local old_print, old_dofile, old_loadfile = print, dofile, loadfile

-- TODO: All these must be baked as byte-code into swc (this would have size penalty though)

-- NOTE: Order is important!

old_dofile("builtin://lua_alchemy/as3/sugar.lua")

-- TODO: Uncomment this as soon as flyield() would be fixed.
--old_dofile("builtin://lua_alchemy/as3/filegetcontents.lua")

old_dofile("builtin://lua_alchemy/as3/toobject.lua")
old_dofile("builtin://lua_alchemy/as3/onclose.lua")
old_dofile("builtin://lua_alchemy/as3/print.lua")

old_dofile("builtin://lua_alchemy/lua/dofile.lua")
old_dofile("builtin://lua_alchemy/lua/print.lua")
