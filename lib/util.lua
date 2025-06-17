local M = {}

M.ripairs = (function()
  local function iter(t, i)
    i = i - 1
    if i > 0 then
      return i, t[i]
    end
  end

  return function(t)
    return iter, t, #t + 1
  end
end)()

function M.defaultdict(t)
  local f
  if type(t) == "function" then
    f = t
  elseif type(t) == "table" then
    f = function() return M.merge({}, t) end
  else
    f = function() return t end
  end

  return setmetatable({}, {
    __index = function(t, k)
      t[k] = f(k)
      return t[k]
    end,
  })
end

function M.merge(dest, src)
  for k, v in pairs(src) do
    dest[k] = v
  end
  return dest
end

function M.parse_item_amount(input)
  if type(input) == "number" then return input end

  local _, _, n, unit = string.find(input, "^(-?%d+)(%a+)$")

  if n == nil then
    error(("Not a number: %s"):format(input))
  end

  n = tonumber(n)
  unit = string.lower(unit)

  if unit == "s" then
    return n * 64
  end

  error(("Invalid unit: %s"):format(unit))
end

return M
