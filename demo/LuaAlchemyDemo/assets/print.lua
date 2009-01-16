-- Override print to go to canvas

print = function(...)
 local n = select("#", ...)
 local t = {}
 for i = 1, n do
   t[i] = tostring(select(i, ...))
 end
 output.text = as3.tolua(output.text) .. table.concat(t, "\t") .. "\n"
end

-- Test print function
print("Hello from Lua")
print("Another print message")
print("Yet another print message")
print("Goodbye")
