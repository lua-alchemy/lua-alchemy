-- The Computer Language Benchmarks Game
-- http://shootout.alioth.debian.org/
-- contributed by Sam Roberts

require"coroutine"

-- first and only argument is number of token passes
local N = assert(tonumber(arg[1]))

-- fixed size pool
local poolsize = 503

-- cache these to avoid global environment lookups
local resume = coroutine.resume
local yield = coroutine.yield

local threads = {}

function body(token)
  while true do
    token = yield(token+1)
  end
end

for id = 1,poolsize do
  threads[id] = coroutine.create(body)
end

local id = 0
local ok
local token = 0
repeat
  id = (id%poolsize)+1
  ok, token = resume(threads[id], token)
  -- skip check for whether body raised exception
  --assert(ok)
until token == N

print(id)

