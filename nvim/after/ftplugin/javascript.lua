local fn = vim.fn
local cmd = vim.cmd
local keymap = vim.keymap.set
local u = require("config.utils")
--------------------------------------------------------------------------------

-- Abbreviations / spelling
vim.cmd.inoreabbrev("<buffer> cosnt const")

--------------------------------------------------------------------------------

-- Build
keymap("n", "<leader>r", function()
	cmd.update()
	local output = fn.system(('osascript -l JavaScript "%s"'):format(fn.expand("%:p")))
	local logLevel = vim.v.shell_error > 0 and u.error or u.trace
	vim.notify(output, logLevel)
end, { buffer = true, desc = " JXA run" })

-- Open regex in regex101 and regexper (railroad diagram)
keymap("n", "g/", function()
	-- keymaps assume a/ and i/ mapped as regex textobj via treesitter textobj
	vim.cmd.normal { '"zya/', bang = false } -- yank outer regex
	vim.cmd.normal { "vi/", bang = false } -- select inner regex for easy replacement

	local regex = fn.getreg("z")
	local pattern = regex:match("/(.*)/")
	local flags = regex:match("/.*/(%l*)")
	---@diagnostic disable-next-line: param-type-mismatch, undefined-field
	local replacement = fn.getline("."):match('replace ?%(/.*/.*, ?"(.-)"')

	-- https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url = "https://regex101.com/?regex=" .. pattern .. "&flags=" .. flags
	if replacement then url = url .. "&subst=" .. replacement end

	os.execute("open '" .. url .. "'") -- opening method on macOS
end, { desc = " Open next regex in regex101", buffer = true })
