vim.bo.commentstring = "/* %s */" -- PENDING https://github.com/neovim/neovim/pull/27043

--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------

-- CONFIG read project-specific config
-- HACK workaround for `opt.exrc` not working with neovide
vim.defer_fn(function()
	local configPath = (vim.loop.cwd() or "") .. "/.nvim.lua"
	local projectConfigExists = vim.loop.fs_stat(configPath) ~= nil
	if projectConfigExists then vim.cmd.source(configPath) end
end, 200)
