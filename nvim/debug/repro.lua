-- save as `minimal-config.lua`
-- run via: `nvim -u minimal-config.lua`
--------------------------------------------------------------------------------
local spec = {
	{
		"folke/snacks.nvim",
		opts = {
			input = {
				enabled = true,
			},
			styles = {
				input = {
					backdrop = true,
				},
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				always_show_tabs = true,
			},
			tabline = {
				lualine_a = {
					{ "datetime", style = "%H:%M:%S" },
				},
			},
		},
	},
}

--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }

vim.cmd.colorscheme("tokyonight-day")
