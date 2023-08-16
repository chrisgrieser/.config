local cmd = vim.cmd
local keymap = vim.keymap.set
local u = require("config.utils")
--------------------------------------------------------------------------------

u.applyTemplateIfEmptyFile("applescript")

--------------------------------------------------------------------------------

-- poor man's formatting
keymap({ "n", "i", "x" }, "<D-s>", function()
	cmd.mkview(2)
	u.normal("gg=G")
	vim.lsp.buf.format { async = false } -- still used for null-ls-codespell
	cmd.loadview(2)
	cmd.write()
end, { buffer = true, desc = "Save & Format" })
