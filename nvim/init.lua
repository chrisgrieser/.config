-- CORE CONFIG
vim.g.mapleader = ","
LinterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- read from .zshenv
VimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv
UpdateCounterThreshhold = 25 -- for plugin update statusline

--------------------------------------------------------------------------------

-- TEMP to avoid trouble with devices not upgraded yet
if vim.version().minor >= 9 then vim.loader.enable() end 

--------------------------------------------------------------------------------

---try to require the module, and do not error when one of them cannot be
---loaded. But do notify if there was an error.
---@param module string module to load
local function tryRequire(module)
	local success, req = pcall(require, module)
	if success then return req end

	local msg = "Error loading " .. module
	local notifyInstalled, notify = pcall(require, "notify")
	if notifyInstalled then
		notify(" " .. msg)
	else
		vim.cmd.echoerr(msg)
	end
end

--------------------------------------------------------------------------------

local borderstyle = tryRequire("config.borderstyle")
if borderstyle then borderstyle.set("single") end -- should come before lazy
tryRequire("config.lazy")
tryRequire("config.utils")

if vim.fn.has("gui_running") then tryRequire("config.gui-settings") end
tryRequire("config.theme-config")

tryRequire("config.options-and-autocmds")
tryRequire("config.keybindings")
tryRequire("config.folding-keymaps")
tryRequire("config.clipboard")

tryRequire("config.automating-nvim")
tryRequire("config.clipboard")
tryRequire("config.user-commands")
tryRequire("config.abbreviations")
