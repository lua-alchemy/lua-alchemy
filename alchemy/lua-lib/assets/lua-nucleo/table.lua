-- table.lua: proxy file for various utilities for managing lua tables
-- This file is a part of lua-nucleo library
-- Copyright (c) lua-nucleo authors (see file `COPYRIGHT` for the license)

local tappend_many,
      table_utils
      = import 'lua-nucleo/table-utils.lua'
      {
        'tappend_many'
      }

return tappend_many(
    { }, -- Appending to empty table, to avoid changing any existing namespaces
    table_utils,
    import 'lua-nucleo/tdeepequals.lua' (),
    import 'lua-nucleo/tserialize.lua' (),
    import 'lua-nucleo/tstr.lua' ()
  )
