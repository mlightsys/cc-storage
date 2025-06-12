local INDEX = "index.lt"

local util = require("lib/util")
local ripairs, defaultdict = util.ripairs, util.defaultdict

local M = {}

local function move_item(dest, destIdx, src, srcIdx, limit)
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

local SlotEntry = setmetatable({}, {
  __call = function(cls, inventory, slot)
    return setmetatable({
      inventory = inventory,
      slot = slot,
    }, cls)
  end
})

function SlotEntry:__index(k)
  if k == "free" then
    local item = self.inventory[self.slot]
    return item.limit - item.count
  end

  return SlotEntry[k]
end

function SlotEntry:store(src, slot, limit)
  return move_item(self.inventory, self.slot, src, slot, limit)
end

M.ItemAllocator = setmetatable({}, {
  __call = function(cls, inventories)
    local slots = defaultdict({})

    for _, inventory in ripairs(inventories) do
      for slot, item in ripairs(inventory) do
        local free = item.limit - item.count
        if free == 0 then goto next_slot end
        table.insert(slots[item.name or ""], SlotEntry(inventory, slot))

        ::next_slot::
      end
    end

    return setmetatable({slots = slots}, cls)
  end
})
M.ItemAllocator.__index = M.ItemAllocator

function M.ItemAllocator:store(src, slot, limit)
  local item = src[slot]
  local item_name = item.name
  for _, entry in ripairs(self.slots[item_name]) do
    local n = entry:store(src, slot, limit)

    if limit then limit = limit - n end
    if limit == 0 then return true, 0 end

    if entry.free == 0 then
      table.remove(self.slots[item_name])
    end

    if item.count == 0 then return true, limit end
  end

  for _, entry in ripairs(self.slots[""]) do
    local n = entry:store(src, slot, limit)

    if limit then limit = limit - n end
    if limit == 0 then return true, 0 end

    table.remove(self.slots[""])
    if entry.free ~= 0 then
      table.insert(self.slots[item_name], entry)
    end

    if item.count == 0 then return true, limit end
  end

  return false, limit
end

function M.Inventory(c)
  local entry = {name = peripheral.getName(c)}
  local l = c.list()
  local itemLimits = {}
  for i=1,c.size() do
    local slot = l[i] or {}
    local key = slot.name or ""
    local limit = itemLimits[key]
    if limit == nil then
      limit = c.getItemLimit(i)
      itemLimits[key] = limit
    end

    table.insert(entry, {
      name = slot.name,
      count = slot.count or 0,
      limit = limit,
      nbt = slot.nbt,
    })
  end
  return entry
end

M.Index = {}
M.Index.__index = M.Index

function M.Index.from_inventories(inventories)
  return setmetatable(inventories, M.Index)
end

function M.Index.from_file()
  local f, err = fs.open(INDEX, "r")
  if f == nil then error(err) end

  local t = textutils.unserialize(f.readAll())
  f.close()
  return setmetatable(t, M.Index)
end

function M.Index:write()
  local f, err = fs.open(INDEX, "w")
  if f == nil then error(err) end

  local s = textutils.serialize(self, {compact = true})
  f.write(s)
  f.close()
  return string.len(s)
end


return M
