local u = require("config.utils")

--------------------------------------------------------------------------------

vim.bo.commentstring = "/* %s */"

-- toggle !important (useful for debugging selectors)
vim.keymap.set("n", "<leader>i", function()
	local line = vim.api.nvim_get_current_line()
	if line:find("!important") then
		line = line:gsub(" !important", "")
	else
		line = line:gsub(";?$", " !important;", 1)
	end
	vim.api.nvim_set_current_line(line)
end, { buffer = true, desc = " Toggle !important", nowait = true })

-- HACK workaround for `opt.exrc` not working with neovide
vim.defer_fn(function()
	local cwd = vim.uv.cwd()
	if not cwd then return end
	local configPath = cwd .. "/.nvim.lua"
	if u.fileExists(configPath) then vim.cmd.source(configPath) end
end, 200)
