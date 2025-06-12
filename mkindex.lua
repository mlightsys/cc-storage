local inventory = require("lib/inventory")
local Inventory, Index = inventory.Inventory, inventory.Index

local barrels = {peripheral.find("minecraft:barrel")}
local l = {}

for _, b in ipairs(barrels) do
  local name = peripheral.getName(b)
  print(("Processing %s"):format(name))
  table.insert(l, Inventory(b))
end

local n = Index.from_inventories(l):write()

print(("Wrote %d bytes of index"):format(n))
