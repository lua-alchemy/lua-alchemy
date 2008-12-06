--- The Great Computer Language Shootout
-- http://shootout.alioth.debian.org/
--
-- contributed by Mike Pall


local BUFSIZE = 2^12

local lower, gfind, format = string.lower, string.gfind, string.format
local read, write = io.read, io.write

local nwords = 0
local words = {}
local count = setmetatable({}, { __index = function(t, w)
  local n = nwords + 1
  nwords = n
  words[n] = w
  return 0
end })

while true do
  local lines, rest = read(BUFSIZE, "*l")
  if lines == nil then break end
  if rest then lines = lines..rest end
  for w in gfind(lower(lines), "%l+") do count[w] = count[w] + 1 end
end

table.sort(words, function (a, b)
  local ca, cb = count[a], count[b]
  return ca == cb and a > b or ca > cb -- we know a ~= b
end)

for i=1,nwords do
  local w = words[i]
  write(format("%7d %s\n", count[w], w))
end
