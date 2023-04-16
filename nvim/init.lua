--------------------------------------------------------------------------------
vim.g.mapleader = ","
vim.g.maplocalleader = "!"

-- TODO remove this condition later on
if vim.version().minor >= 9 then vim.loader.enable() end 

---try to require the module, and do not error when one of them cannot be
---loaded. But do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, _ = pcall(require, module)
	if success then return end
	local msg = "Error loading " .. module
	local notifyLoaded, _ = pcall(require, "notify")
	if notifyLoaded then
		vim.notify(" " .. msg, vim.log.levels.ERROR)
	else
		vim.cmd.echoerr(msg)
	end
end

--------------------------------------------------------------------------------

safeRequire("config.lazy")

if vim.fn.has("gui_running") then safeRequire("config.gui-settings") end
safeRequire("config.theme-config")
safeRequire("config.keybindings")
safeRequire("config.options-and-autocmds")

safeRequire("config.textobject-keymaps")
safeRequire("config.folding")
safeRequire("config.clipboard")

safeRequire("config.automating-nvim")
safeRequire("config.user-commands")
safeRequire("config.abbreviations")
