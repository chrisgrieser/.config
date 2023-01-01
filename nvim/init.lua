-- CORE CONFIG
vim.g.mapleader = ","
borderStyle = "single" -- none|single|double|rounded|shadow|solid
linterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- reading from .zshenv
vimDataDir = vim.env.DATA_DIR .. "/vim-data/"

--------------------------------------------------------------------------------

require("config.lazy")
require("config.utils") -- should come after lazy

if isGui() then
	require("config.theme-settings") -- should come early to start with the proper theme
	require("config.gui-settings")
	require("config.notifications")
else
	require("config.terminal-only")
end
require("config.options-and-autocmds")
require("config.automating-nvim")
require("config.keybindings")
require("config.user-commands")
require("config.lualine")
require("config.treesitter")

require("config.lsp-and-diagnostics") -- should come before linter and debugger
require("config.linter")
require("config.debugger")

require("config.comments")
require("config.textobjects")
require("config.telescope")
