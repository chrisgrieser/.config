-- CORE CONFIG
vim.g.mapleader = ","
LinterConfig = vim.env.DOTFILE_FOLDER .. "/linter-configs/" -- read from .zshenv
VimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv
UpdateCounterThreshhold = 25 -- for plugin update statusline

local ok, borderstyle = pcall(require, "config.borderstyle")
if ok then borderstyle.set("single") end -- should come before lazy

---try to require the module, and do not error when one of them cannot be
---loaded. But do notify if there was an error.
---@param module string module to load
local function tryRequire(module)
	local success = pcall(require, module)
	if not success then
		local msg = "Error loading " .. module
		local notifyInstalled, notify = pcall(require, "notify")
		if notifyInstalled then
			notify(" " .. msg)
		else
			vim.cmd.echoerr(msg)
		end
	end
end

--------------------------------------------------------------------------------

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
