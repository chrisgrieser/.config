-- save as `minimal-config.lua`
-- run via: `nvim -u minimal-config.lua`
--------------------------------------------------------------------------------
local spec = {
	"echasnovski/mini.pairs",
	config = function(_, opts)
		require("mini.pairs").setup(opts)

		require("mini.pairs").map("i", "<", {
			action = "open",
			pair = "<>",
			neigh_pattern = "\r.",
			register = { cr = false },
		})
		require("mini.pairs").map("i", ">", {
			action = "close",
			pair = "<>",
			register = { cr = false },
		})
	end,
}

--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
--------------------------------------------------------------------------------
