-- Provides
--   Syntax sugar support for as3 module
--   as3.package()
-- Depends on
--   as3.canvas

--[[

obj * newindex -> as3.set
obj * index -> callobj
obj * call -> error
callobj * index -> callobj.value * index -> callobj
callobj * newindex -> callobj.value * newindex -> as3.set
callobj * as3.any -> as3.any(callobj.value, ...)
callobj * call -> as3.call(callobj.value, ...)
callobj * tostring -> as3.call(callobj.value, "toString")

--]]

local old_trace, old_call, old_tolua, old_type = as3.trace, as3.call, as3.tolua, as3.type

do
  local proxy_tag = newproxy()

  local unproxy = function(o)
    local mt = getmetatable(o)
    if mt and mt[1] == proxy_tag then
      o = mt:value()
    end
    return o
  end

  local make_callobj
  do
    local index = function(t, k)
      --as3.trace("callobj index", k)
      return make_callobj(getmetatable(t):value(), k)
    end

    local newindex = function(t, k, v)
      --as3.trace("callobj newindex", k)
      as3.set(getmetatable(t):value(), k, v)
    end

    -- Enforcing dot notation for performance
    local call = function(t, ...)
      local mt = getmetatable(t) -- Note no value() call here
      --as3.trace("callobj call", mt.obj_, mt.key_)
      return as3.call(mt.obj_, mt.key_, ...)
    end

    local value = function(self)
      --as3.trace("callobj value", self.value_ ~= nil, self.obj_, self.key_)
      if self.value_ == nil then
        self.value_ = as3.get(self.obj_, self.key_)
      end
      return self.value_
    end

    local tostring_callobj = function(t) -- TODO: Untested. Ensure this works.
      local str = old_tolua(old_call(unproxy(t), "toString"))
      local tt = type(str)
      if tt == "number" then
        str = tostring(str)
      elseif tt ~= "string" then
        --old_trace("BAD1", tt, old_type(str))
        str = "("..(old_type(t) or type(t))..")" -- TODO: Dump something meaningful!
      end
      return str
    end

    make_callobj = function(t, k)
      if not as3.is_as3_value(t) then
        error("as3 object expected, got "..(as3.type(t) or type(t)))
      end
      return setmetatable(
          {},
          {
            proxy_tag;

            obj_ = t;
            key_ = k;
            value_ = nil;

            value = value;

            __index = index;
            __newindex = newindex;
            __call = call;
            __tostring = tostring_callobj;
          }
        )
    end
  end

  do -- Patch as3 metatable
    local mt = debug.getmetatable(assert(as3.canvas))

    mt.__index = function(t, k)
      return make_callobj(t, k)
    end

    mt.__newindex = function(t, k, v)
      return as3.set(t, k, v)
    end

    mt.__tostring = function(t)
      local str = old_call(t, "toString")
      local tt = type(str)
      if tt == "number" then
        str = tostring(str)
      elseif tt ~= "string" then
        --old_trace("BAD2", tt, old_type(str), type(str), type(t), old_type(t))
        str = "("..(old_type(t) or type(t))..")" -- TODO: Dump something meaningful!
      end
      return str
    end
  end

  do -- Patch methods
    local methods =
    {
      "release", "tolua", "get", "set", "assign",
      "call", "type", "namespacecall", "trace",
      "class", "class2", "new", "new2", "is_as3_value"
    }

    for _, name in ipairs(methods) do
      local old_fn = as3[name]
      as3[name] = function(...)
        --[[
        if name ~= "trace" then
          --as3.trace("[as3.sugar]", name, "args:", ...)
        end
        --]]
        local n = select("#", ...)
        local args = {}
        for i = 1, n do
          args[i] = unproxy(select(i, ...))
        end
        return old_fn(unpack(args, 1, n))
      end
    end
  end

--[[

as3.package * newindex -> error
as3.package * index -> pkgobj(nil)
as3.package * call(path) -> pkgobj(splitpath(path))

splitpath(path) -> namespace, class, key

pkgobj * index(key) ->
  pkgobj.namespace = pkgobj.namespace.."."..pkgobj.class
  pkgobj.class = pkgobj.key
  pkgobj.key = key

pkgobj * as3.any -> as3.any(as3.get(as3.class2(pkgobj.namespace, pkgobj.class), pkgobj.key)))

pkgobj * colon_call(pkgobj, ...) ->
  as3.call(as3.class2(pkgobj.namespace, pkgobj.class), pkgobj.key, ...)

pkgobj * dot_call(...) ->
  if pkgobj.key == "new" then
    as3.new2(pkgobj.namespace, pkgobj.class, ...)
  elseif pkgobj.key == "class" then
    as3.class2(pkgobj.namespace, pkgobj.class, ...)
  else
    as3.namespacecall(pkgobj.namespace.."."..pkgobj.class, pkgobj.key, ...)
  end

pkgobj * newindex(key, value) ->
  pkgobj.namespace = pkgobj.namespace.."."..pkgobj.class
  pkgobj.class = pkgobj.key
  pkgobj.key = key
  as3.set(as3.class2(pkgobj.namespace, pkgobj.class), pkgobj.key, value)

--]]

  do -- Patch for as3.package()
    local make_pkgobj
    do
      -- Note this would not work as __eq metamethod, since metatables are different
      local pkgobj_equals = function(lhs, rhs)
        local lhsmt, rhsmt = getmetatable(lhs), getmetatable(rhs)
        --[[as3.trace(
            "eq",
            lhsmt.namespace_, lhsmt.class_, lhsmt.key_,
            rhsmt.namespace_, rhsmt.class_, rhsmt.key_
          )--]]
        return lhsmt.namespace_ == rhsmt.namespace_
           and lhsmt.class_ == rhsmt.class_
           and lhsmt.key_ == rhsmt.key_
      end

      local splitpath = function(...) -- TODO: Test this well!
        -- TODO: Huge overhead, but simple. Rewrite.

        local str = table.concat({...}, "."):gsub(":+", ".")
        local buf = {}
        for match in str:gmatch("([^.:]+)") do
          buf[#buf + 1] = match
        end

        local key = table.remove(buf)
        local class = table.remove(buf)
        local namespace = table.concat(buf, ".")

        return namespace, class, key
      end

      local path2 = function(self, ...)
        local class = assert(self.key_, "path is empty")

        local namespace = self.class_
        if namespace and namespace ~= "" then
          local prefix = self.namespace_
          if prefix and prefix ~= "" then
            namespace = prefix .. "." .. namespace
          end
        else
          namespace = self.namespace_
        end

        return namespace, class, ...
      end

      local value = function(self)
        if self.value_ == nil then
          --as3.trace("value", self.namespace_, self.class_, self.key_)
          self.value_ = as3.get(as3.class2(self.namespace_, self.class_), self.key_)
        end
        return self.value_
      end

      local call = function(t, ...)
        local mt = assert(getmetatable(t))

        local self = (...)
        local selfmt = getmetatable(self)

        local key = mt.key_

        --as3.trace("call begin")

        if
          selfmt == mt
          and ( -- Hack. Need to find out if self is our parent
              mt.namespace_.."."..mt.class_ == selfmt.namespace_.."."..selfmt.class_.."."..selfmt.key_
            )
        then
          -- colon call mode
          --as3.trace("colon call", mt.namespace_, mt.class_, mt.key_, as3.tolua(...))
          return as3.call(as3.class2(mt.namespace_, mt.class_), key, ...)
        end

        if key == "new" then
          -- new object mode
          --as3.trace("new call", mt.namespace_, mt.class_, mt.key_)
          return as3.new2(mt.namespace_, mt.class_, ...)
        elseif key == "class" then
          -- class object mode
          --as3.trace("class call", mt.namespace_, mt.class_, mt.key_)
          return as3.class2(mt.namespace_, mt.class_, ...)
        end

        -- dot call mode
        --as3.trace("dot call", mt.namespace_, mt.class_, mt.key_)
        return as3.namespacecall(mt.namespace_.."."..mt.class_, key, ...)
      end

      local newindex = function(t, k, v)
        -- Note subindices in k are not supported
        --as3.trace("newindex", getmetatable(t):path2(k))
        as3.set(getmetatable(t):value(), k, v)
      end

      local index = function(t, k)
        --as3.trace("index", getmetatable(t):path2(k))
        return make_pkgobj(getmetatable(t):path2(k))
      end

      local tostring_pkgobj = function(t) -- TODO: This function always MUST return string!
        local namespace, path = getmetatable(t):path2()
        if namespace then
          path = tostring(namespace) .. "::" .. tostring(path)
        end
        --old_trace("tostring", path)
        return path
      end

      make_pkgobj = function(...)
        local namespace, class, key = splitpath(...)
        return setmetatable(
            {},
            {
              proxy_tag;

              namespace_ = namespace;
              class_ = class;
              key_ = key;
              value_ = nil;

              path2 = path2;
              value = value;

              __index = index;
              __newindex = newindex;
              __call = call;
              __tostring = tostring_pkgobj;
            }
          )
      end
    end

    as3.package = setmetatable(
        {},
        {
          __index = function(t, k)
            return make_pkgobj(k)
          end;

          __call = function(t, ...)
            return make_pkgobj(...)
          end;

          __newindex = function(t, k, v)
            error("as3.package is read-only")
          end;
        }
      )
  end
end
