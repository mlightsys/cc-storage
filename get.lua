local util = require("lib/util")
local ripairs = util.ripairs
local storage = require("lib/storage")
local container = require("lib/container")

local chest = peripheral.find("minecraft:chest")

local cache = storage.load()
local freeSlots = container.find_free_slots({container.itemize(chest)})
local argv = {...}

local function move_item(container, slot, count, entry, name)
  local toMove = math.min(entry.free, count)
  storage.move(entry.container, entry.slot, container, slot, name, toMove)
  entry.free = entry.free - toMove
  return toMove
end

local function get(item_name, amount)
  if (string.find(item_name, ":", 1, true)) == nil then
    item_name = "minecraft:" .. item_name
  end

  for _, container in ipairs(cache.list) do
    for slot, item in ipairs(container) do
      if item.name ~= item_name then goto next_slot end

      for _, entry in ripairs(freeSlots[item_name]) do
        amount = amount - move_item(container.name, slot, math.min(amount, item.count), entry, item_name)
        if amount == 0 then return end
        if entry.free == 0 then
          table.remove(freeSlots[item_name])
        end
        if item.count == 0 then goto next_slot end
      end

      for _, entry in ripairs(freeSlots[""]) do
        amount = amount - move_item(container.name, slot, math.min(amount, item.count), entry, item_name)
        if amount == 0 then return end
        table.remove(freeSlots[""])
        if entry.free ~= 0 then
          table.insert(freeSlots[item_name], entry)
        end
        if item.count == 0 then goto next_slot end
      end

      -- All free slots exhausted, amount still not 0
      print(("ERROR: Not enough space in chest (needs space for %d more %s)"):format(amount, item_name))
      goto fun_end -- For some reason a return statement here is invalid

      ::next_slot::
    end
  end
  -- Went through entire storage, amount still not 0
  print(("ERROR: Not enough %s in storage (%d left)"):format(item_name, amount))

  ::fun_end::
end

ok, err = pcall(get, argv[1], argv[2])
storage.sync()
if ok then
  print("File transfer successful :3")
else
  error(err)
end
