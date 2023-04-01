-- CORE CONFIG
vim.g.mapleader = ","
LinterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- read from .zshenv
VimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv
UpdateCounterThreshhold = 20 -- for plugin update statusline

require("config.borderstyle").set("single") -- must come before lazy

--------------------------------------------------------------------------------

require("config.lazy")
require("config.utils") 

if vim.g.neovide then require("config.gui-settings") end
require("config.theme-config")

require("config.options-and-autocmds")
require("config.keybindings")

require("config.automating-nvim")
require("config.textobject-keymaps")
require("config.clipboard")
require("config.user-commands")
require("config.abbreviations")

