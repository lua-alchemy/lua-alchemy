-- Provides
--   as3.prints()
--   as3.makeprinter()
-- Depends on
--   sugar

-- TODO: We really want to rewrite these to C.

do
  -- Concatenates arguments a-la print and returns them.
  -- Does not append a newline
  as3.prints = function(...)
   local n = select("#", ...)
   local t = {}
   for i = 1, n do
     t[i] = tostring(select(i, ...))
   end
   return table.concat(t, "\t")
  end
end

do
  -- Creates print function which does output to given AS3 object text property.
  as3.makeprinter = function(obj)
    return function(...)
      obj.text = as3.tolua(obj.text) .. as3.prints(...) .. "\n"
    end
  end
end
