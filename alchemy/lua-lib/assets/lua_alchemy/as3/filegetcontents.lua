-- Provides
--   as3.filegetcontents()
-- Depends on
--   sugar

-- TODO: Fix this as soon as Alchemy team clarifies situations

assert(as3.class, "must have sugar installed")

do
  local load_done, load_err = true, nil

  -- Setup loader
  local loader = as3.new2("flash.net", "URLLoader")
  loader.dataFormat = as3.class("flash.net.URLLoaderDataFormat").BINARY
  loader.addEventListener(
      as3.class("flash.events.Event").COMPLETE,
      function(e)
        as3.trace("FGC: COMPLETE")
        load_done, load_err = true, nil
      end,
      false, 0, true -- TODO: Do we really need the weak reference here?
    )
  loader.addEventListener(
      as3.class("flash.events.IOErrorEvent").IO_ERROR,
      function(e)
        as3.trace("FGC: IO_ERROR")
        load_done, load_err = true, "IOError: "..as3.tolua(e.toString())
      end,
      false, 0, true -- TODO: Do we really need the weak reference here?
    )
  loader.addEventListener(
      as3.class("flash.events.SecurityErrorEvent").SECURITY_ERROR,
      function(e)
        as3.trace("FGC: SECURITY_ERROR")
        load_done, load_err = true, "SecurityError: "..as3.tolua(e.toString())
      end,
      false, 0, true -- TODO: Do we really need the weak reference here?
    )

  local init = function(filename)
    as3.trace("FGC: BEGIN INIT", filename)

    assert(load_done == true, "nested call detected")

    load_done, load_err = false, nil

    loader.load(as3.new2("flash.net", "URLRequest", filename))

    as3.trace("FGC: END INIT")
  end

  local wait = function()
    as3.trace("FGC: BEGIN WAIT")

    while not load_done do
      --for i = 1, 1000 do as3.flyield() end
      --as3.trace("* FGC: loaded:", loader.bytesLoaded, "total:", loader.bytesTotal, "type", as3.type(loader.data), "data", loader.data)
      as3.flyield()
      load_done = true -- TODO: Debugging, remove ASAP
    end

    as3.trace("FGC: END WAIT")
  end

  local cleanup = function()
    as3.trace("FGC: BEGIN CLEANUP")

    assert(load_done == true, "cleanup before done")

    local result, error
    if not load_err then
      result = loader.data -- TODO: Cleanup loader!
    else
      error = load_err
    end

    load_done, load_err = true, nil

    as3.trace("FGC: END CLEANUP")

    return result, error
  end

  as3.filegetcontents = function(filename)
    init(filename)

    wait()

    return cleanup()
  end
end
