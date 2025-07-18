local URL = "https://raw.githubusercontent.com/mlightsys/cc-storage/refs/heads/main/"

local files = {
  "lib/inventory.lua",
  "lib/util.lua",
  "storage.lua",
}

local function download_file(url, path)
  local f = fs.open(path, "w")
  local r = http.get(url)
  f.write(r.readAll())
  f.close()
  r.close()
end

for _, p in ipairs(files) do
  print(("Downloading %s"):format(p))
  download_file(URL .. p, p)
end
print("Download complete")
