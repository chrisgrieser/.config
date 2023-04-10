require("config.utils")
--------------------------------------------------------------------------------

-- poor man's formatting
keymap({ "n", "i", "x" }, "<D-s>", function()
	cmd.mkview(2)
	normal("gg=G") 
	vim.lsp.buf.format { async = false } -- still used for null-ls-codespell
	cmd.loadview(2)
	cmd.write()
end, { buffer = true, desc = "Save & Format" })

--------------------------------------------------------------------------------

-- Build
keymap("n", "<leader>r", function()
	cmd.update()
	local output = fn.system(('osascript "%s"'):format(expand("%:p")))
	local logLevel = vim.v.shell_error > 0 and logError or logTrance
	vim.notify(output, logLevel)
end, { buffer = true, desc = " AppleScript run" })

