--------------------------------------------------------------------------------
vim.g.mapleader = ","

if vim.version().minor >= 9 then -- TODO remove this condition later on
	vim.loader.enable()
end 

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

require("config.utils").setBorderstyle("single") -- should come before lazy

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
