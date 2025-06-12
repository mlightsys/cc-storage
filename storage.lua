local util = require("lib/util")
local inventory = require("lib/inventory")

local defaultdict = util.defaultdict
local ItemAllocator, Inventory, Index = inventory.ItemAllocator, inventory.Inventory, inventory.Index

local chest = peripheral.find("minecraft:chest")
local index

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

local function usage()
  local capacity = 0
  local countMap = defaultdict(0)
  for _, inventory in ipairs(index) do
    for _, item in ipairs(inventory) do
      capacity = capacity + item.limit
      if item.name ~= nil then
        countMap[item.name] = countMap[item.name] + item.count
      end
    end
  end

  local total = 0
  local counts = {}
  for item, count in pairs(countMap) do
    table.insert(counts, {item = item, count = count})
    total = total + count
  end

  table.sort(counts, function(a, b) return a.count > b.count end)

  for _, entry in ipairs(counts) do
    print(("%s - %d"):format(entry.item, entry.count))
  end

  print(("Used: %d/%d"):format(total, capacity))
end

local function mkindex()
  local barrels = {peripheral.find("minecraft:barrel")}
  local l = {}
  for _, b in ipairs(barrels) do
    local name = peripheral.getName(b)
    print(("Processing %s"):format(name))
    table.insert(l, Inventory(b))
  end

  local index = Index.from_inventories()
  local n = index:write()

  print(("Wrote %d bytes of index"):format(n))

  return index
end

function main(command, ...)
  if command == "reindex" then
    mkindex(...)
    return
  end

  local ok, output = pcall(Index.from_file)

  if not ok then
    print("WARNING: Index not found, recreating")
    index = mkindex()
  else
    index = output
  end

  local commands = {
    get = get,
    store = store,
    usage = usage,
  }
  local cmd = commands[command]
  if cmd == nil then
    print(("ERROR: No such command: %s"):format(command))
    return
  end

  local ok, err = pcall(commands[command], ...)
  index:write()
  if not ok then error(err) end
end

main(...)
