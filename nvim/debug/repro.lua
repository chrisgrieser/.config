-- INFO run via: `nvim -u minimal-config.lua -- foobar.js`
--------------------------------------------------------------------------------
local spec = {
	{
		"akinsho/toggleterm.nvim",
		opts = true,
		cmd = "ToggleTerm",
	},
}


vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc (Terminal Mode)" })

--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
