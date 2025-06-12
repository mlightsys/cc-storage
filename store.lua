local chest = peripheral.find("minecraft:chest")
local ripairs = require("lib/util").ripairs

local storage = require("lib/storage")
local container = require("lib/container")

local cache = storage.load()

local function store()
  local chest = container.itemize(chest)
  local allocator = container.item_allocator(cache.list)

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
storage.sync()

if ok then
  print("Items inserted successfully :3")
else
  error(err)
end
