vim.diagnostic.enable(false, { bufnr = 0 })
vim.opt_local.colorcolumn = ""
vim.opt_local.wrap = true

--------------------------------------------------------------------------------

-- `:bwipeout` so it isn't saved in oldfiles
Bufmap { "q", vim.cmd.bwipeout, desc = "Quit" }
Bufmap { "<D-w>", vim.cmd.bwipeout, desc = "Quit" }

-- `gO` opens the heading-selection in vim help files.
-- (Only for txt-help files, so lazy-generated markdown help files are not affected.)
local txtHelpFile = vim.api.nvim_buf_get_name(0):match("%.(%w+)$") == "txt"
if txtHelpFile then
	Bufmap { "gs", "gO", remap = true }
	Bufmap { "gd", "<C-]>", desc = "Goto definition" }
end
