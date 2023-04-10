-- CORE CONFIG
vim.g.mapleader = ","
VimDataDir = vim.env.DATA_DIR .. "/vim-data/" -- read from .zshenv

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
		notify(" " .. msg, vim.log.levels.ERROR)
	else
		vim.cmd.echoerr(msg)
	end
end

--------------------------------------------------------------------------------

---Sets the global BorderStyle variable and the matching BorderChars Variable.
---See also https://neovim.io/doc/user/api.html#nvim_open_win()
---(BorderChars is needed for Harpoon and Telescope, both of which do not accept
---a Borderstyle string.)
---@param str string none|single|double|rounded|shadow|solid
local function setBorderstyle(str)
	BorderStyle = str
	if str == "single" then
		BorderChars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
		BorderHorizontal = "─"
	elseif str == "double" then
		BorderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
		BorderHorizontal = "═"
	elseif str == "rounded" then
		BorderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
		BorderHorizontal = "─"
	elseif str == "none" then
		BorderChars = { "", "", "", "", "", "", "", "" }
		BorderHorizontal = ""
	end
	-- default: rounded
	if not BorderChars then BorderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" } end
end

setBorderstyle("single") -- should come before lazy

tryRequire("config.utils")

tryRequire("config.lazy")

if vim.fn.has("gui_running") then tryRequire("config.gui-settings") end
tryRequire("config.theme-config")

tryRequire("config.options-and-autocmds")
tryRequire("config.keybindings")
tryRequire("config.folding-keymaps")
tryRequire("config.textobject-keymaps")
tryRequire("config.clipboard")

tryRequire("config.automating-nvim")
tryRequire("config.clipboard")
tryRequire("config.user-commands")
tryRequire("config.abbreviations")
