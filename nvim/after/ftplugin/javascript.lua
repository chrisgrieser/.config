local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

abbr("<buffer> cosnt const")
abbr("<buffer> local const") -- habit from writing too much lua
abbr("<buffer> -- //") -- habit from writing too much lua

u.applyTemplateIfEmptyFile("js")

--------------------------------------------------------------------------------

-- auto-convert string to template string when typing `${..}`
vim.api.nvim_create_autocmd("InsertLeave", {
	buffer = 0,
	callback = function()
		local curLine = vim.api.nvim_get_current_line()
		local correctedLine = curLine:gsub([["(.*${.-}.*)"]], "`%1`"):gsub([['(.*${.-}.*)']], "`%1`")
		vim.api.nvim_set_current_line(correctedLine)
	end,
})

--------------------------------------------------------------------------------

-- Open regex in regex101 and regexper (railroad diagram)
keymap("n", "<localleader>r", function()
	-- keymaps assume a/ and i/ mapped as regex textobj via treesitter textobj
	vim.cmd.normal { '"zya/', bang = false } -- yank outer regex
	vim.cmd.normal { "vi/", bang = false } -- select inner regex for easy replacement

	local regex = fn.getreg("z")
	local pattern = regex:match("/(.*)/")
	local flags = regex:match("/.*/(%l*)")
	local replacement = vim.api.nvim_get_current_line():match('replace ?%(/.*/.*, ?"(.-)"')

	-- https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url = "https://regex101.com/?regex=" .. pattern .. "&flags=" .. flags
	if replacement then url = url .. "&subst=" .. replacement end

	os.execute("open '" .. url .. "'") -- opening method on macOS
end, { desc = " Open next regex in regex101", buffer = true })
