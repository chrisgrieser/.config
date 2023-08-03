local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")
--------------------------------------------------------------------------------

vim.cmd.inoreabbrev("<buffer> cosnt const")
vim.cmd.inoreabbrev("<buffer> -- //") -- habit from writing too much lua

u.applyTemplateIfEmptyFile("js")

--------------------------------------------------------------------------------

keymap("n", "<leader>r", function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local allLines = ""
	for _, line in ipairs(lines) do
		allLines = allLines .. line .. "\n"
	end
	allLines = allLines:gsub("'", "//'") -- escape single quotes
	local output = fn.system([[osascript -l JavaScript -e ']] .. allLines .. [[']])
	output = output:gsub("\n$", "")
	vim.notify(output)
end, { desc = " Run JXA file", buffer = true })

--------------------------------------------------------------------------------

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
