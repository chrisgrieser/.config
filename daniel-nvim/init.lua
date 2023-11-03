
-- edit from dotfiles folder

-- set vim options; this will load the file at `.config/nvim/lua/options.lua`
require("options")

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Split up config to use a folder: this automatically load everything in `.config/nvim/lua/plugins/*.lua`.
require("lazy").setup("plugins")
