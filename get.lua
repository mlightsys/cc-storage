local util = require("lib/util")
local inventory = require("lib/inventory")
local ItemAllocator, Inventory, Index = inventory.ItemAllocator, inventory.Inventory, inventory.Index

local chest = peripheral.find("minecraft:chest")

local index = Index.from_file()
local argv = {...}

local function get(item_name, amount)
  if (string.find(item_name, ":", 1, true)) == nil then
    item_name = "minecraft:" .. item_name
  end

  local allocator = ItemAllocator({Inventory(chest)})
  local ok
  for _, container in ipairs(index) do
    for slot, item in ipairs(container) do
      if item.name ~= item_name then goto next_slot end

      ok, amount = allocator:store(container, slot, amount)

      if not ok then
        -- All free slots exhausted, amount still not 0
        print(("ERROR: Not enough space in chest (needs space for %d more %s)"):format(amount, item_name))
        return
      end

      if amount == 0 then return end

      ::next_slot::
    end
  end
  -- Went through entire storage, amount still not 0
  print(("ERROR: Not enough %s in storage (%d left)"):format(item_name, amount))
end

ok, err = pcall(get, argv[1], argv[2])
index:write()
if ok then
  print("File transfer successful :3")
else
  error(err)
end
