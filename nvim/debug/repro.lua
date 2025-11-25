-- save as `minimal-config.lua`
-- run via: `nvim -u minimal-config.lua`
--------------------------------------------------------------------------------
local spec = {
	"chrisgrieser/nvim-origami",
	opts = {},
}

--------------------------------------------------------------------------------
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH -- make LSPs available
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
--------------------------------------------------------------------------------
