-- Demo namespace calls to setTimeout() and getTimer()

print = as3.makeprinter(output)

print("Expect timer to fire in 1 second")

local start = as3.namespace.flash.utils.getTimer()

as3.namespace.flash.utils.setTimeout(
	function (s)
		local now = as3.namespace.flash.utils.getTimer()
		local time = as3.tolua(now) - as3.tolua(start)
		print(as3.tolua(s) .. " in " .. time .. " milliseconds")
	end, 1000, "Timeout Fired")