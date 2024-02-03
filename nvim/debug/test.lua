

local path = "/Users/chrisgrieser/repos/nvim-genghis/.git/hooks"
local found = path:find("/%.git/") ~= nil
vim.notify("👽 found: " .. tostring(found))

