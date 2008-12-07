-- $Id: strcat.lua-2.lua,v 1.1 2004-11-10 06:44:59 bfulgham Exp $
-- http://shootout.alioth.debian.org

-- this version uses the native string concatenation operator
-- Modified for Lua 5 by Brent Fulgham

local n = tonumber((arg and arg[1]) or 1)
local str = ""
for i=1,n do
    str = str.."hello\n"
end
print(string.len(str))
