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
end

return M
