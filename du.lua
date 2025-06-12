local util = require("lib/util")
local inventory = require("lib/inventory")

local Index = inventory.Index
local defaultdict = util.defaultdict

local index = Index.from_file()

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
