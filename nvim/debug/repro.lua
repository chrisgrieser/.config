local plugins = {
	-- {
	-- 	"williamboman/mason-lspconfig.nvim",
	-- 	dependencies = { "williamboman/mason.nvim", opts = true },
	-- 	opts = { ensure_installed = { "lua_ls" } },
	-- },
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	init = function() require("lspconfig")["lua_ls"].setup{} end,
	-- },
	{
		"chrisgrieser/nvim-various-textobjs",
		lazy = false,
		dev = true,
		opts = { useDefaultKeymaps = true },
	},
}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	-- stylua: ignore
	vim.fn.system { "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath }
end
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup(plugins, {
	dev = {
		path = os.getenv("HOME") .. "/Repos",
		fallback = true, -- use remote repo when local repo doesn't exist
	},
})

-- Convenience stuff, not strictly necessary
vim.g.neovide_scale_factor = 1.8
vim.cmd.colorscheme("habamax")
vim.opt.signcolumn = "yes:2"

--------------------------------------------------------------------------------
