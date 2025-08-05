-- save as `minimal-config.lua`
-- run via: `nvim -u minimal-config.lua`
--------------------------------------------------------------------------------
local spec = {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		lazy = false,
		opts = {
			file_types = { "markdown" },
			code = {
				border = "thick",
				position = "left",
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main", -- new versions follow `main`
		lazy = false,
		build = ":TSUpdate",
		init = function()
			local parsersToInstall = { "markdown", "markdown_inline" }
			vim.defer_fn(function() require("nvim-treesitter").install(parsersToInstall) end, 1000)

			vim.api.nvim_create_autocmd("FileType", {
				desc = "User: enable treesitter highlighting",
				pattern = "markdown",
				callback = function() vim.treesitter.start() end,
			})
		end,
	},
}

--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
--------------------------------------------------------------------------------
