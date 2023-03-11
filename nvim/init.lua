-- CORE CONFIG
vim.g.mapleader = ","
LinterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- read from .zshenv
VimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv
UpdateCounterThreshhold = 25 -- for lazy
require("config.borderstyle").set("single") -- must come before lazy

--------------------------------------------------------------------------------

require("config.lazy")
require("config.utils") -- must come after lazy

if vim.g.neovide then
	require("config.gui-settings")
	require("config.theme-config")
else
	require("config.terminal-only")
end
require("config.lsp-and-diagnostics") 

require("config.options-and-autocmds")
require("config.automating-nvim")
require("config.keybindings")

require("config.textobjects")
require("config.clipboard")
require("config.build-system")
require("config.user-commands")
require("config.abbreviations")
