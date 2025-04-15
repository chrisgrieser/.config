-- save as `minimal-config.lua`
-- run via: `nvim -u minimal-config.lua`
--------------------------------------------------------------------------------
local spec = {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = "all",
			highlight = { enable = true },
			indent = {
				enable = true,
				disable = { "typescript", "javascript", "markdown" },
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = "nvim-treesitter/nvim-treesitter",
		keys = {
			{ "af", "<cmd>TSTextobjectSelect @function.outer<CR>", mode = { "x", "o" } },
		},
		main = "nvim-treesitter.configs",
		opts = {
			textobjects = {
				select = {
					lookahead = true,
					include_surrounding_whitespace = false,
				},
			},
		},
	},
}

--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
--------------------------------------------------------------------------------
