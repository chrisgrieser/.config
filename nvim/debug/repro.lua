local plugins = {
	-- { "folke/lazydev.nvim", ft = "lua", opts = true },
	{
		"neovim/nvim-lspconfig",
		-- dependencies = "folke/neodev.nvim",
		config = function()
			-- require("lspconfig").lua_ls.setup {}
			require("lspconfig").ltex.setup {
				settings = {
					ltex = {
						dictionary = { ["en-US"] = "mistke" },
						diagnosticSeverity = {
							MORFOLOGIK_RULE_EN_US = "hint",
							default = "info",
						},
					},
				},
			}
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim", opts = true },
		opts = {
			ensure_installed = { "lua-language-server", "ltex-ls" },
			run_on_start = true,
		},
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
