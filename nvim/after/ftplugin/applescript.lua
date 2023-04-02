require("config.utils")
--------------------------------------------------------------------------------

-- poor man's formatting
Keymap({ "n", "i", "x" }, "<D-s>", function()
	Cmd.mkview(2)
	Normal("gg=G") 
	vim.lsp.buf.format { async = false } -- still used for null-ls-codespell
	Cmd.loadview(2)
	Cmd.write()
end, { buffer = true, desc = "Save & Format" })

--------------------------------------------------------------------------------

-- Build
Keymap("n", "<leader>r", function()
	Cmd.update()
	local output = Fn.system(('osascript "%s"'):format(Expand("%:p")))
	local logLevel = vim.v.shell_error > 0 and LogError or LogTrace
	vim.notify(output, logLevel)
end, { buffer = true, desc = " AppleScript run" })

