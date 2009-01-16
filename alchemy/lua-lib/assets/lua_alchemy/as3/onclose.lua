-- Provides
--   as3.onclose()

do
  local obj, list

  local obj_mt =
  {
    __gc = function()
      if list then
        for i, fn in ipairs(list) do
          local res, err = pcall(fn)
          if not res then
            as3.trace("error calling gc finalizer", i, fn)
            as3.trace(err)
          end
        end
      end
    end;
  }

  as3.onclose = function(fn)
    assert(type(fn) == "function", "function expected")

    if not obj then
      obj = newproxy()
      debug.setmetatable(obj, obj_mt)

      list = {}
    end

    list[#list + 1] = fn
  end
end
