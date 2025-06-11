local util = require("lib/util")
local ripairs, defaultdict = util.ripairs, util.defaultdict

local M = {}

function M.find_free_slots(containers)
  -- Map of item names (ids) to list of free slots for that item (unfull stacks)
  -- slots with no items are stored under empty string key
  local slots = defaultdict({})

  for _, data in ripairs(containers) do
    for i, slot in ripairs(data) do
      local free = slot.limit - slot.count
      if free == 0 then goto next_slot end
      table.insert(slots[slot.name or ""], {
        container = data.name,
        slot = i,
        free = free,
      })

      ::next_slot::
    end
  end

  return slots
end

function M.itemize(c)
  local entry = {name = peripheral.getName(c)}
  local l = c.list()
  local emptySlot
  for i=1,c.size() do
    local slot = l[i]
    if slot == nil then
      if emptySlot == nil then
        emptySlot = {
          count = 0,
          limit = c.getItemLimit(i),
        }
      end
      table.insert(entry, util.copy(emptySlot))
    else
      table.insert(entry, {
        name = slot.name,
        count = slot.count,
        limit = c.getItemLimit(i),
      })
    end
  end
  return entry
end

return M
