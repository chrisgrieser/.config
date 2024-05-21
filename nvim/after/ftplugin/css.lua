vim.bo.commentstring = "/* %s */"

-- toggle !important (useful for debugging selectors)
vim.keymap.set("n", "<leader>i", function()
	local line = vim.api.nvim_get_current_line()
	if line:find("!important") then
		line = line:gsub(" ?!important", "")
	else
		line = line:gsub(";?$", " !important;", 1)
	end
	vim.api.nvim_set_current_line(line)
end, { buffer = true, desc = " Toggle !important", nowait = true })

-- workaround for `opt.exrc` not working with neovide
-- for security reasons, restricted to `~/repos/shimmering-focus`
vim.defer_fn(function()
	local u = require("config.utils")
	local exrc = vim.fs.normalize("~/repos/shimmering-focus/.nvim.lua")
	if vim.uv.cwd() == vim.fs.dirname(exrc) and u.fileExists(exrc) then
		vim.cmd.source(exrc)
	end
end, 200)
