local plugins = {
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim", opts = true },
		config = function()
			require("mason-tool-installer").setup {
				ensure_installed = { "lua-language-server", "ltex-ls" },
				run_on_start = true,
			}
			vim.cmd.MasonToolsInstall()
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = "folke/neodev.nvim",
		config = function()
			require("lspconfig").lua_ls.setup {}
			require("lspconfig").ltex.setup {
				settings = {
					ltex = {
						language = "en-US",
						dictionary = {
							["en-US"] = "Neovim",
						},
					},
				},
			}
		end,
	},
}

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

--------------------------------------------------------------------------------
