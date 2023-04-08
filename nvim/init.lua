-- CORE CONFIG
vim.g.mapleader = ","
LinterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- read from .zshenv
VimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv
UpdateCounterThreshhold = 25 -- for plugin update statusline


--------------------------------------------------------------------------------

local function tryRequire(module)
	local success = tryRequire(module)
	if not success then vim.cmd.echoerr("Error loading " .. module) end
end


tryRequire("config.lazy")
tryRequire("config.utils")

if vim.g.neovide then tryRequire("config.gui-settings") end
tryRequire("config.theme-config")

tryRequire("config.options-and-autocmds")
tryRequire("config.keybindings")

tryRequire("config.automating-nvim")
tryRequire("config.textobject-keymaps")
tryRequire("config.clipboard")
tryRequire("config.user-commands")
tryRequire("config.abbreviations")
