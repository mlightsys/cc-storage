local CACHE = "cache.lt"

local M = {cache = {}}

function M.move(dest, destIdx, src, srcIdx, limit)
  local destPeri = peripheral.wrap(dest.name)
  local srcPeri = peripheral.wrap(src.name)

  local destSlot = dest[destIdx]
  local srcSlot = src[srcIdx]

  local limit = math.min(limit or math.huge, srcSlot.count, destSlot.limit - destSlot.count)
  if limit == 0 then return 0 end

  local n = srcPeri.pushItems(dest.name, srcIdx, limit, destIdx)

  if destSlot.count == 0 and n > 0 then
    destSlot.name = srcSlot.name
    destSlot.limit = destPeri.getItemLimit(destIdx)
  end
  destSlot.count = destSlot.count + n

  srcSlot.count = srcSlot.count - n
  if srcSlot.count <= 0 then
    srcSlot.name = nil
    srcSlot.limit = srcPeri.getItemLimit(srcIdx)
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
