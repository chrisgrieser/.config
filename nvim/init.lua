--------------------------------------------------------------------------------
vim.g.mapleader = ","

if vim.version().minor >= 9 then -- TODO remove this condition later on
	vim.loader.enable()
end 

---try to require the module, and do not error when one of them cannot be
---loaded. But do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
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

safeRequire("config.lazy")

if vim.fn.has("gui_running") then safeRequire("config.gui-settings") end
safeRequire("config.theme-config")

safeRequire("config.options-and-autocmds")
safeRequire("config.keybindings")
safeRequire("config.folding-keymaps")
safeRequire("config.textobject-keymaps")
safeRequire("config.clipboard")

safeRequire("config.automating-nvim")
safeRequire("config.clipboard")
safeRequire("config.user-commands")
safeRequire("config.abbreviations")
