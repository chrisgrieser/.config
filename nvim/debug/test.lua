local function getLine(lnum) return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, true)[1] end

local startLnum = vim.api.nvim_win_get_cursor(0)[1]
local text = getLine(startLnum)
vim.notify("👾 text: " .. tostring(text))
