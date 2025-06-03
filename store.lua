local chest = peripheral.find("minecraft:chest")
local ripairs = require("lib/util").ripairs

print("Processing storage unit state, please wait...")
local storage = require("lib/storage")
local container = require("lib/container")

local cache = storage.load()
local freeSlots = container.find_free_slots(cache.list)

local function move_item(slot, count, entry, name)
  local toMove = math.min(entry.free, count)
  storage.move(entry.container, entry.slot, chest, slot, name, toMove)
  entry.free = entry.free - toMove
  return toMove
end

local function store()
  for slot, item in pairs(chest.list()) do
    local count = item.count

    if item.nbt ~= nil then
      print(("WARNING: Item %s is unsupported (contains NBT data)"):format(item.name))
      goto item_moved
    end

    for i, incomplete in ripairs(freeSlots[item.name]) do
      count = count - move_item(slot, count, incomplete, item.name)
      if incomplete.free == 0 then
        table.remove(freeSlots[item.name], i)
      end

      if count == 0 then
        goto item_moved
      end
    end

    for i, incomplete in ripairs(freeSlots[""]) do
      count = count - move_item(slot, count, incomplete, item.name)
      table.remove(emptySlots, i)
      if incomplete.free > 0 then
        table.insert(freeSlots[item.name], incomplete)
      end

      if count == 0 then
        goto item_moved
      end
    end

    print(("Failed to allocate %d of %s"):format(count, item.name))

    ::item_moved::
  end
end

ok, err = pcall(store)
storage.sync()

if ok then
  print("Items inserted successfully :3")
end
