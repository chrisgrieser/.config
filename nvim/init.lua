-- CORE CONFIG
vim.g.mapleader = ","
BorderStyle = "single" -- none|single|double|rounded|shadow|solid
LinterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- read from .zshenv
VimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv
UpdateCounterThreshhold = 25

--------------------------------------------------------------------------------

require("config.lazy")
require("config.utils") -- should come after lazy

if isGui() then
	require("config.gui-settings")
	ThemeSettings()
else
	require("config.terminal-only")
end
require("config.lualine")
require("config.treesitter")

require("config.options-and-autocmds")
require("config.automating-nvim")
require("config.keybindings")

require("config.lsp-and-diagnostics") -- should come before linter since it includes mason setup
require("config.linter")

require("config.comments")
require("config.textobjects")
require("config.clipboard")
require("config.user-commands")
