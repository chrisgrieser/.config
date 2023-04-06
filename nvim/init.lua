-- CORE CONFIG
vim.g.mapleader = ","
LinterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- read from .zshenv
VimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv
UpdateCounterThreshhold = 25 -- for plugin update statusline

local ok, borderstyle = pcall(require, "config.borderstyle")
if ok then borderstyle.set("single") end -- should come before lazy

--------------------------------------------------------------------------------

pcall(require, "config.lazy")
pcall(require, "config.utils")

if vim.g.neovide then pcall(require, "config.gui-settings") end
pcall(require, "config.theme-config")

pcall(require, "config.options-and-autocmds")
pcall(require, "config.keybindings")

pcall(require, "config.automating-nvim")
pcall(require, "config.textobject-keymaps")
pcall(require, "config.clipboard")
pcall(require, "config.user-commands")
pcall(require, "config.abbreviations")
