local util = require("lib/util")
local storage = require("lib/storage")
local ripairs, defaultdict = util.ripairs, util.defaultdict

local M = {}

local SlotEntry = setmetatable({}, {
  __call = function(cls, t)
    return setmetatable(t, cls)
  end
})

function SlotEntry:__index(k)
  if k == "free" then
    local slot = self.container[self.slot]
    return slot.limit - slot.count
  end

  return SlotEntry[k]
end

function SlotEntry:store(src, slot, limit)
  return storage.move(self.container, self.slot, src, slot, limit)
end

local ItemAllocator = setmetatable({}, {
  __call = function(cls, containers)
    local slots = defaultdict({})

    for _, data in ripairs(containers) do
      for i, slot in ripairs(data) do
        local free = slot.limit - slot.count
        if free == 0 then goto next_slot end
        table.insert(slots[slot.name or ""], SlotEntry({
          container = data,
          slot = i,
        }))

        ::next_slot::
      end
    end

    return setmetatable({slots = slots}, cls)
  end
})
ItemAllocator.__index = ItemAllocator

function ItemAllocator:store(src, slot, limit)
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

M.item_allocator = ItemAllocator

function M.itemize(c)
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

return M
