local cmd = vim.cmd
local expand = vim.fn.expand
local fn = vim.fn
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

--------------------------------------------------------------------------------

-- Build
keymap("n", "<leader>r", function()
	cmd.update()
	local output = fn.system(('osascript "%s"'):format(expand("%:p")))
	local logLevel = vim.v.shell_error > 0 and u.error or u.trace
	vim.notify(output, logLevel)
end, { buffer = true, desc = " AppleScript run" })

