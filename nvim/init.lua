-- CORE CONFIG
vim.g.mapleader = ","
borderStyle = "single" -- none|single|double|rounded|shadow|solid
linterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- read from .zshenv
vimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv
updateCounterThreshhold = 15

--------------------------------------------------------------------------------

require("config.lazy")
require("config.utils") -- should come after lazy

if isGui() then
	require("config.gui-settings")
	themeSettings()
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
