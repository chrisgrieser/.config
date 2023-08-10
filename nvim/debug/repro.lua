local plugins = {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", opts = {} },
		opts = { ensure_installed = { "lua_ls" } },
	},
	{
		"neovim/nvim-lspconfig",
		init = function() require("lspconfig")["lua_ls"].setup({}) end,
	},
}

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
	 vim.fn.system {
		  'git',
		  'clone',
		  '--depth=1',
		  '--filter=blob:none',
		  '--single-branch',
		  'https://github.com/folke/lazy.nvim.git',
		  lazypath,
	 }
end
vim.opt.runtimepath:prepend(lazypath)
require('lazy').setup(plugins)

vim.g.neovide_scale_factor = 1.8 -- Convenience stuff, not strictly necessary

--------------------------------------------------------------------------------
