print = function(...)
 local n = select("#", ...)
 local t = {}
 for i = 1, n do
   t[i] = tostring(select(i, ...))
 end
 as3.set(output, "text", as3.get(output, "text") .. table.concat(t, "\t") .. "\n")
end

print("Hello from Lua")
print("Another print message")
print("Yet another print message")
print("Goodbye")