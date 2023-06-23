local fn = vim.fn
local cmd = vim.cmd
local keymap = vim.keymap.set
local u = require("config.utils")
--------------------------------------------------------------------------------

-- Abbreviations / spelling
vim.cmd.inoreabbrev("<buffer> cosnt const")

u.applyTemplateIfEmptyFile("js")

--------------------------------------------------------------------------------

-- Build
keymap("n", "<leader>r", function()
	cmd.update()
	local output = fn.system(('osascript -l JavaScript "%s"'):format(fn.expand("%:p")))
	local logLevel = vim.v.shell_error > 0 and u.error or u.trace
	vim.notify(output, logLevel)
end, { buffer = true, desc = " JXA run" })

