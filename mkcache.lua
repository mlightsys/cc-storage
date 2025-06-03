local container = require("lib/container")

local barrels = {peripheral.find("minecraft:barrel")}
local cache = {}

for _, b in ipairs(barrels) do
  local name = peripheral.getName(b)
  print(("Processing %s"):format(name))
  table.insert(cache, container.itemize(b))
end

-- table.sort(cache, function(a, b) return a.name < b.name end)

local s = textutils.serialize(cache, {compact = true})
local f = fs.open("cache.lt", "w")
f.write(s)
f.close()
print(("Wrote %d bytes of cache"):format(s:len()))
