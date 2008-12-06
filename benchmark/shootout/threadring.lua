-- The Computer Language Benchmarks Game
-- http://shootout.alioth.debian.org/
-- contributed by Jason Foreman

require 'coroutine'

local nThreads = 503
local token = tonumber(arg[1])

local threads = {}
local function makethreadfun(id)
   local id = id
   local function threadfun(token, next)
      while true do
         if token == 0 then
            print(id)
            return -1
         end
         token = coroutine.yield(token-1)
      end
   end
   return threadfun
end

for i=1,nThreads+1 do
   threads[i] = coroutine.wrap(makethreadfun(i))
end

local t = 1
repeat
   token = threads[t](token)
   t=(t%nThreads)+1
until token < 0

