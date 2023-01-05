-- CORE CONFIG
vim.g.mapleader = ","
borderStyle = "single" -- none|single|double|rounded|shadow|solid
linterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- read from .zshenv
vimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv

--------------------------------------------------------------------------------

require("config.lazy")
require("config.utils") -- should come after lazy

if isGui() then
	require("config.theme-settings") -- should come early to start with the proper theme
	require("config.gui-settings")
else
	require("config.terminal-only")
end
require("config.lualine")
require("config.treesitter")

require("config.options-and-autocmds")
require("config.automating-nvim")
require("config.keybindings")

require("config.lsp-and-diagnostics") -- should come before linter and debugger, since it includes mason setup
require("config.linter")

require("config.comments")
require("config.textobjects")
require("config.user-commands")
