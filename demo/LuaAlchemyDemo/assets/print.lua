print = function(...)
 local t = {...}
 for k,v in pairs(t) do
   t[k] = tostring(v)
 end
 as3.set(output, "text", as3.get(output, "text") .. table.concat(t,"\t") .. "\n")
end

print("Hello from Lua")
print("Another print message")
print("Yet another print message")
print("Goodbye")