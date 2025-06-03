local CACHE = "cache.lt"

local M = {cache = {}}

function M.move(dest, destSlot, src, srcSlot, name, count)
  local destName, srcName
  if type(src) == "string" then
    srcName = src
    src = peripheral.wrap(src)
  else
    srcName = peripheral.getName(src)
  end

  if type(dest) == "string" then
    destName = dest
    dest = peripheral.wrap(dest)
  else
    destName = peripheral.getName(dest)
  end

  local n = src.pushItems(destName, srcSlot, count, destSlot)

  local destCache = M.cache.map[destName]
  if destCache then
    -- Despoit
    local slot = destCache[destSlot]
    if slot.count == 0 then
      slot.limit = dest.getItemLimit(destSlot)
    end
    slot.name = name
    slot.count = slot.count + count
  end

  local srcCache = M.cache.map[srcName]
  if srcCache then
    -- Extract
    local slot = srcCache[srcSlot]
    slot.count = slot.count - count
    if slot.count <= 0 then
      slot.name = nil
      slot.limit = src.getItemLimit(srcSlot)
    end
  end

  return n
end

function M.load()
  local f = fs.open(CACHE, "r")
  M.cache.list = textutils.unserialize(f.readAll())
  f.close()

  M.cache.map = {}
  for _, entry in ipairs(M.cache.list) do
    M.cache.map[entry.name] = entry
  end
  return M.cache
end

function M.sync()
  local f = fs.open(CACHE, "w")
  f.write(textutils.serialize(M.cache.list, {compact = true}))
  f.close()
end

return M
