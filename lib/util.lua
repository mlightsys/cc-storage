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

function M.map(dest, src, f)
  for i, v in ipairs(src) do
    dest[i] = f(v)
  end
  return dest
end

function M.parse_item_amount(input)
  if type(input) == "number" then return true, input end

  local _, _, n, unit = string.find(input, "^(-?%d+)(%a*)$")

  if n == nil then
    return false, ("Not a number: %s"):format(input)
  end

  n = tonumber(n)
  unit = string.lower(unit)

  if unit == "s" then
    return true, n * 64
  elseif unit == "" then
    return true, n
  end

  return false, ("Invalid unit: %s"):format(unit)
end

function M.colorprint(s, ...)
  local function tokenize(s)
    local tokens = {}
    local textStart = 1

    while true do
      local tagStart, tagEnd, tag = string.find(s, "(<+[^%s%c>]+>+)", textStart)

      if tagStart == nil then break end
      table.insert(tokens, string.sub(s, textStart, tagStart - 1))
      table.insert(tokens, tag)
      textStart = tagEnd + 1
    end

    table.insert(tokens, string.sub(s, textStart))
    return tokens
  end

  local textChunks, fgChunks, bgChunks = {}, {}, {}
  local fgColor, bgColor = "0", "f"
  local args = {...}
  if #args > 0 then
    M.map(args, args, function(s)
      if type(s) ~= "string" then return s end
      return string.gsub(s, "<+[^%s%c>]+>+", "<%0>")
    end)
    s = string.format(s, unpack(args))
  end
  local tokens = tokenize(s)

  for _, t in ipairs(tokens) do
    local _, _, tag = string.find(t, "^<(<*[^%s%c>]+>*)>$")
    if tag ~= nil then
      local _, _, color = string.find(tag, "^fg:(%x)$")
      if color ~= nil then
        fgColor = color
        goto next_token
      end

      local _, _, color = string.find(tag, "^bg:(%x)$")
      if color ~= nil then
        bgColor = color
        goto next_token
      end

      if (string.find(tag, "^%b<>$")) ~= nil then
        t = tag
      else
        error(("Unknown tag: %s"):format(t))
      end
    end

    ::insert::
    table.insert(textChunks, t)
    table.insert(fgChunks, string.rep(fgColor, string.len(t)))
    table.insert(bgChunks, string.rep(bgColor, string.len(t)))

    ::next_token::
  end


  local fg = string.lower(table.concat(fgChunks))
  local bg = string.lower(table.concat(bgChunks))

  term.blit(table.concat(textChunks), fg, bg)

  local _, row = term.getCursorPos()
  term.setCursorPos(1, row + 1)
end

return M
