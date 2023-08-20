local bo = vim.bo
local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

abbr("<buffer> cosnt const")
abbr("<buffer> local const") -- habit from writing too much lua
abbr("<buffer> -- //") -- habit from writing too much lua

--------------------------------------------------------------------------------
-- BUILD

-- setup quickfix list for npm, see also: https://vonheikemen.github.io/devlog/tools/vim-and-the-quickfix-list/
bo.makeprg = "npm run build"
bo.errorformat = " > %f:%l:%c: %trror: %m" .. ",%-G%.%#" -- = ignore remaining lines

keymap("n", "<localleader><localleader>", function()
	cmd.update()
	cmd.redir("@z")
	cmd([[silent make]]) -- silent, to not show up message (redirection still works)
	local output = fn.getreg("z"):gsub(".-\r", "") -- remove first line
	local logLevel = output:find("error") and u.error or u.trace
	vim.notify(output, logLevel)
	cmd.redir("END")
end, { buffer = true, desc = " npm run build" })

--------------------------------------------------------------------------------

-- Open regex in regex101
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
