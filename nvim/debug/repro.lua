-- use new install dir
-- (not needed when debugging regular plugins in most cases not needed)

-- local root = vim.fn.fnamemodify("./debug/install-root", ":p")
-- for _, name in ipairs { "config", "data", "state", "cache" } do
-- 	vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
-- end

--------------------------------------------------------------------------------

-- plugins to debug
local plugins = {
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim", opts = true },
		opts = { ensure_installed = { "lua_ls" } },
	},
	{
		"neovim/nvim-lspconfig",
		init = function() require("lspconfig")["lua_ls"].setup {} end,
	},
	{ -- lsp definitions & references count as virtual text
		"roobert/action-hints.nvim",
		config = function()
			require("action-hints").setup {
				template = {
					definition = { text = " ⊛", color = "#add8e6" },
					references = { text = " ↱%s", color = "#ff6666" },
				},
				use_virtual_text = true,
			}
		end,
	},
}

-- bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	}
end
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup(plugins)

-- basic appearance settings to not make me crazy blsf fsslfs fslfs fslfs flsf
vim.cmd.colorscheme("habamax")
vim.opt.guifont = "JetBrainsMonoNL Nerd Font:h25.2"
vim.opt.signcolumn = "yes:1"

--------------------------------------------------------------------------------
