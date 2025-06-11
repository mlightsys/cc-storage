local util = require("lib/util")
local storage = require("lib/storage")

local defaultdict = util.defaultdict

local cache = storage.load()

local countMap = defaultdict(0)
for _, container in ipairs(cache.list) do
  for _, item in ipairs(container) do
    countMap[""] = countMap[""] + item.limit - item.count
    if item.name ~= nil then
      countMap[item.name] = countMap[item.name] + item.count
    end
  end
end

local empty = countMap[""]
countMap[""] = nil

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

print(("Used: %d/%d"):format(total, total + empty))
