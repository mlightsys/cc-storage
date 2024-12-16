local URL = "https://raw.githubusercontent.com/lvxnull2/cc-storage/refs/heads/main/"

local files = {
  "mkcache.lua",
  "store.lua",
  lib = {
    "storage.lua"
  },
}

local function download_file(url, path)
  local f = fs.open(path, "w")
  r = http.get(url)
  f.write(r.readAll())
  f.close()
  r.close()
end

local function recdl(dir)
  local stack = {{prefix = "/", dir}}

  while #stack > 0 do
    local d = table.remove(stack)
    local prefix = d.prefix
    fs.makeDir(prefix)
    d = d[1]

    for k, v in pairs(d) do
      if type(k) == "string" then
        table.insert(stack, {prefix = fs.combine(prefix, k), v})
      elseif type(k) == "number" then
        local p = fs.combine(prefix, v)
        print(("Downloading %s"):format(p))
        download_file(URL .. p, p)
      end
    end
  end
end

recdl(files)
print("Download complete")
