-- stylua: ignore start
--------------------------------------------------------------------------------
-- INFO Run this config via: `neovide test.lua -- -u repro.lua` or `make debug`
--------------------------------------------------------------------------------
-- INFO set path to my personal working directory. Change back when debugging
-- folke plugins.
local root = vim.fn.fnamemodify("./.repro", ":p")

-- local root = vim.env.WD .. "/repro"

--------------------------------------------------------------------------------

-- Convenience stuff, not strictly necessary
vim.g.neovide_scale_factor = 1.6
vim.fn.system("open -g 'hammerspoon://enlarge-neovide-window'")

--------------------------------------------------------------------------------

-- set stdpaths to use .repro
for _, name in ipairs({ "config", "data", "state", "cache" }) do
	vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

-- bootstrap lazy
local lazypath = root .. "/plugins/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.runtimepath:prepend(lazypath)

-- install plugins with minimal LSP setup
local plugins = {
	"folke/tokyonight.nvim",
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		opts = true,
	},
	-- {
	-- 	"williamboman/mason-lspconfig.nvim",
	-- 	dependencies = { "williamboman/mason.nvim", opts = {} },
	-- 	opts = { ensure_installed = { "lua_ls" } },
	-- },
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	init = function()
	-- 		require("lspconfig")["lua_ls"].setup({})
	-- 	end,
	-- },
}

require("lazy").setup(plugins, {
	root = root .. "/plugins",
})

vim.cmd.colorscheme("tokyonight")

--------------------------------------------------------------------------------
