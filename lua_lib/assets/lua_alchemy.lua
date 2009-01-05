-- Save overridden functions just in case
local old_print, old_dofile, old_loadfile = print, dofile, loadfile

-- TODO: All these must be baked as byte-code into swc

-- NOTE: Order is important!

old_dofile("builtin://lua_alchemy/lua/strict.lua")

old_dofile("builtin://lua_alchemy/as3/canvas.lua")
old_dofile("builtin://lua_alchemy/as3/sugar.lua")
old_dofile("builtin://lua_alchemy/as3/file_get_contents.lua")
old_dofile("builtin://lua_alchemy/as3/toobject.lua")

old_dofile("builtin://lua_alchemy/lua/dofile.lua")
old_dofile("builtin://lua_alchemy/lua/print.lua")
