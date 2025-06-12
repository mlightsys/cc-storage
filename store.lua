local chest = peripheral.find("minecraft:chest")
local ripairs = require("lib/util").ripairs

local inventory = require("lib/inventory")
local ItemAllocator, Index, Inventory = inventory.ItemAllocator, inventory.Index, inventory.Inventory

local index = Index.from_file()

local function store()
  local chest = Inventory(chest)
  local allocator = ItemAllocator(index)

  for slot, item in ipairs(chest) do
    if item.name == nil then goto item_moved end

    if item.nbt ~= nil then
      print(("WARNING: Item %s is unsupported (contains NBT data)"):format(item.name))
      goto item_moved
    end

    local ok = allocator:store(chest, slot)

    if not ok then
      print(("Failed to allocate %d of %s"):format(count, item.name))
    end

    ::item_moved::
  end
end

ok, err = pcall(store)
index:write()

if ok then
  print("Items inserted successfully :3")
else
  error(err)
end
