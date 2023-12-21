--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local anHTTPRequest = 222
local anHttpRequest = 222

-- vim.notify("🪚 anHTTPRequest: " .. tostring(anHTTPRequest))
-- vim.notify("🪚 anHttpRequest: " .. tostring(anHttpRequest))
-- ALL_UPPER_CASE_WORD = "%u%u+"


vim.keymap.set("i", "<C-f>", "<Esc><cmd>lua require('spider').motion('w')<CR>i")
vim.keymap.set("i", "<C-b>", "<Esc><cmd>lua require('spider').motion('b')<CR>i")
