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
callobj * call -> as3.call(callobj.value, callobj.key, ...)

--]]

do
  local proxy_tag = newproxy()

  local make_callobj
  do
    local index = function(t, k)
      return make_callobj(as3.get(getmetatable(t):value(), k))
    end

    local newindex = function(t, k, v)
      as3.set(as3.get(getmetatable(t):value(), k), v)
    end

    -- Enforcing dot notation for performance
    local call = function(t, ...)
      local mt = getmetatable(t) -- Note no value() call here
      return as3.call(mt.obj_, mt.key_, ...)
    end

    local value = function(self)
      if self.value_ == nil then
        self.value_ = as3.get(self.obj_, self.key_)
      end
      return self.value_
    end

    make_callobj = function(t, k)
      assert(as3.is_as3_value(t), "as3 object expected")
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
          }
        )
    end
  end

  local unproxy = function(o)
    local mt = getmetatable(o)
    if mt and mt[1] == proxy_tag then
      o = mt:value()
    end
    return o
  end

  do -- Patch as3 metatable
    local mt = debug.getmetatable(assert(as3.canvas))

    mt.__index = function(t, k)
      return make_callobj(t, k)
    end

    mt.__newindex = function(t, k, v)
      return as3.set(t, k, v)
    end
  end

  do -- Patch methods
    local methods =
    {
      "release", "tolua", "get", "set", "assign",
      "call", "type", "namespacecall", "trace",
      "class", "class2", "new", "new2"
    }

    for _, name in ipairs(methods) do
      local old_fn = as3[name]
      as3[name] = function(...)
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
    as3.new2(pkgobj.namespace.."."..pkgobj.class, ...)
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
          --as3.trace("value", self.namespace_, self.class_, self.key_, debug.traceback())
          self.value_ = as3.get(as3.class2(self.namespace_, self.class_), self.key_)
        end
        return self.value_
      end

      local call = function(t, self, ...)
        local mt = getmetatable(t)
        local selfmt = getmetatable(self)

        --as3.trace("call begin")

        if
          selfmt
          and ( -- Hack. Need to find out if self is our parent
              mt.namespace_.."."..mt.class_ == selfmt.namespace_.."."..selfmt.class_.."."..selfmt.key_
            )
        then
          -- colon call mode
          --as3.trace("colon call", mt.namespace_, mt.class_, mt.key_, as3.tolua(...))
          return as3.call(as3.class2(mt.namespace_, mt.class_), mt.key_, ...)
        end

        if mt.key_ ~= "new" then
          -- dot call mode
          --as3.trace("dot call", mt.namespace_, mt.class_, mt.key_)
          return as3.namespacecall(mt.namespace_.."."..mt.class_, mt.key_, self, ...)
        end

        -- new object mode
        --as3.trace("new call", mt.namespace_, mt.class_, mt.key_)
        return as3.new2(mt.namespace_, mt.class_, ...)
      end

      local newindex = function(t, k, v)
        -- Note subindices in k are not supported
        as3.set(getmetatable(t):value(), k, v)
      end

      local index = function(t, k)
        --as3.trace("index", getmetatable(t):path2(k))
        return make_pkgobj(getmetatable(t):path2(k))
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
