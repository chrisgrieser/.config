-- save as `minimal-config.lua`
-- run via: `nvim -u minimal-config.lua`
--------------------------------------------------------------------------------
local spec = {
}

--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = {} }
--------------------------------------------------------------------------------

-- FIX broken `:Inspect` https://github.com/neovim/neovim/issues/31675
-- can be removed on the version after 0.10.3
vim.hl = vim.highlight

vim.cmd.colorscheme("tokyonight-day")
