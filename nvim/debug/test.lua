local path = "/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Games"
local name, ext = path:match(".*/(.+%.(.+))")
vim.notify("👾 ext: " .. tostring(ext))
vim.notify("👾 name: " .. tostring(name))
