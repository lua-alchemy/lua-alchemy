local socket = require "socket" -- LuaSocket-2.0-beta2 or newer required

local M, reply_size, request_size = 100, 4096, 64
local N = tonumber(arg and arg[1]) or 1

local function client(ls, coserver)
  local repsize = reply_size
  local request = string.rep(" ", request_size)
  local resume, len = coroutine.resume, string.len
  resume(coserver, ls)
  local sk = socket.connect(ls:getsockname())
  sk:settimeout(0)
  local replies = 0
  for i=1,N*M do
    local ok, err, sent = sk:send(request)
    while not ok do
      resume(coserver)
      ok, err, sent = sk:send(request, 1+sent)
    end
    resume(coserver)
    local msg, err, part = sk:receive(repsize)
    while not msg do
      resume(coserver)
      msg, err, part = sk:receive(repsize-len(part), part)
    end
    replies = replies + 1
  end
  io.write("replies: ", replies, "\tbytes: ", sk:getstats(), "\n")
  sk:close()
end

local function server(ls)
  local reqsize = request_size
  local reply = string.rep(" ", reply_size)
  local yield, len = coroutine.yield, string.len
  ls:settimeout(0)
  local sk = ls:accept()
  while not sk do
    yield()
    sk = ls:accept()
  end
  sk:settimeout(0)
  for i=1,N*M do
    yield()
    local msg, err, part = sk:receive(reqsize)
    while not msg do
      yield()
      msg, err, part = sk:receive(reqsize-len(part), part)
    end
    local ok, err, sent = sk:send(reply)
    while not ok do
      yield()
      ok, err, sent = sk:send(reply, 1+sent)
    end
  end
  sk:close()
end

client(socket.bind("127.0.0.1", 0), coroutine.create(server))
