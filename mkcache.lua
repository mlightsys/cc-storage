local barrels = {peripheral.find("minecraft:barrel")}
local cache = {}

for _, b in ipairs(barrels) do
  local name = peripheral.getName(b)
  print(("Processing %s"):format(name))
  local size = b.size()
  local entry = {name = name}
  local l = b.list()
  for i=1,size do
    local item = l[i] or {}
    local stackSize = b.getItemLimit(i)
    entry[i] = {
      name = item.name,
      count = item.count or 0,
      limit = stackSize,
    }
  end
  table.insert(cache, entry)
end

-- table.sort(cache, function(a, b) return a.name < b.name end)

local s = textutils.serialize(cache, {compact = true})
local f = fs.open("cache.lt", "w")
f.write(s)
f.close()
print(("Wrote %d bytes of cache"):format(s:len()))
