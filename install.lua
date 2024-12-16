local URL = "https://raw.githubusercontent.com/lvxnull2/cc-storage/refs/heads/main/"

local files = {
  "lib/storage.lua",
  "mkcache.lua",
  "store.lua",
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
