local path = "/Users/chrisgrieser/.config/nvim/lua/plugins/noice-and-notification.lua"
local name = vim.fs.basename(path)
vim.notify("👾 name: " .. tostring(name))
local maxLength = 25 --CONFIG
if #name > maxLength then name = vim.trim(name:sub(1, maxLength)) .. "…" end
local _, devicons = pcall(require, "nvim-web-devicons")
local extension = name:match("%w+$")
local icon = devicons.get_icon(name, extension) or devicons.get_icon(name, vim.vim.bo.ft)
local out = icon .. " " .. name
vim.notify("👾 out: " .. vim.inspect(out))
