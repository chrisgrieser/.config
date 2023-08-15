local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

-- https://github.com/echasnovski/mini.operators/blob/main/doc/mini-operators.txt#L214
vim.b.minioperators_config = {
	evaluate = {
		-- TODO this only works for linewise textobjs, not yet charwise.
		-- also, there might still be an issue will all the escpaing 🙈
		func = function(content)
			local lines = table.concat(content.lines, "\n")
			local shellCmd = 'osascript -l JavaScript -e "' .. lines:gsub('"', '\\"') .. '"'
			local evaluatedOut = vim.fn.system(shellCmd):gsub("\n$", "")
			return evaluatedOut
		end,
	},
}

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
keymap("n", "g/", function()
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
