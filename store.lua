local chest = peripheral.find("minecraft:chest")
local incompleteStacks = setmetatable({}, {
  __index = function(t, k)
    t[k] = {}
    return t[k]
  end,
})
local ripairs = (function()
  local function iter(t, i)
    i = i - 1
    if i ~= 0 then
      return i, t[i]
    end
  end

  return function(t)
    return iter, t, #t + 1
  end
end)()

local emptySlots = {}

print("Processing storage unit state, please wait...")
local storage = require("lib/storage")

local cache = storage.load()
for _, data in ipairs(cache.list) do
  for i, item in ipairs(data) do
    local slotLimit = item.limit
    if item.count == 0 then
      table.insert(emptySlots, {
        container = data.name,
        slot = i,
        free = slotLimit,
      })
      goto next_item
    end

    local free = slotLimit - item.count
    if free == 0 then goto next_item end

    table.insert(incompleteStacks[item.name], {
      container = data.name,
      slot = i,
      free = free,
    })

    ::next_item::
  end
end

local function move_item(slot, count, entry, name)
  local toMove = math.min(entry.free, count)
  storage.move(entry.container, entry.slot, chest, slot, name, toMove)
  entry.free = entry.free - toMove
  return toMove
end

for slot, item in pairs(chest.list()) do
  local incompStackList = incompleteStacks[item.name]
  local count = item.count

  for i, incomplete in ripairs(incompStackList) do
    count = count - move_item(slot, count, incomplete, item.name)
    if incomplete.free == 0 then
      table.remove(incompStackList, i)
    end

    if count == 0 then
      goto item_moved
    end
  end

  for i, incomplete in ripairs(emptySlots) do
    count = count - move_item(slot, count, incomplete, item.name)
    table.remove(emptySlots, i)
    if incomplete.free > 0 then
      table.insert(incompStackList, incomplete)
    end

    if count == 0 then
      goto item_moved
    end
  end

  print(("Failed to allocate %d of %s"):format(count, item.name))

  ::item_moved::
end

storage.sync()

print("Items inserted successfully :3")
