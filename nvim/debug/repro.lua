local plugins = {
	{
		"folke/noice.nvim",
		dependencies = "MunifTanjim/nui.nvim",
		opts = {
			cmdline = {
				view = "cmdline_popup",
				format = {
					search_down = { view = "cmdline" },
				},
			},
			-- cmdline = {
			-- 	view = "cmdline",
			-- 	format = {
			-- 		search_down = { view = "cmdline" },
			-- 	},
			-- },
		},
	},
}

vim.fn.serverstart("/tmp/nvim_debug.pipe")

--------------------------------------------------------------------------------

for _, name in ipairs { "config", "data", "state", "cache" } do
	vim.env[("XDG_%s_HOME"):format(name:upper())] = "/tmp/nvim-debug/" .. name
end
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) == nil then
	local lazyrepo = "https://github.com/folke/lazy.nvim"
	vim.system({ "git", "clone", "--filter=blob:none", lazyrepo, "--branch=stable", lazypath }):wait()
end
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup(plugins)
