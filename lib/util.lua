local M = {}

M.ripairs = (function()
  local function iter(t, i)
    i = i - 1
    if i ~= 0 then
      return i, t[i]
    end
  end

  return function(t)
    return iter, t, #t + 1
  end
end)()

function M.defaultdict(f)
  if type(f) == "table" then
    f = function() return M.copy(f) end
  end

  return setmetatable({}, {
    __index = function(t, k)
      t[k] = f()
      return t[k]
    end,
  })
end

function M.copy(t)
  local new = {}
  for k, v in pairs(t) do
    new[k] = v
  end
  return new
end

return M
