vim.g.mapleader = ","

vim.loader.enable() -- TODO will be nvim default in later versions

---try to require the module, and do not error when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, _ = pcall(require, module)
	if success then return end
	local msg = "Error loading " .. module
	local notifyLoaded, _ = pcall(require, "notify")
	if notifyLoaded then
		vim.notify(" " .. msg, vim.log.levels.ERROR)
	else
		vim.cmd(('echohl Error | echo "%s" | echohl None'):format(msg))
	end
end

--------------------------------------------------------------------------------

safeRequire("config.lazy")
if vim.fn.has("gui_running") == 1 then safeRequire("config.gui-settings") end
safeRequire("config.theme-customization")
safeRequire("config.options-and-autocmds")

safeRequire("config.keybindings")
safeRequire("config.leader-keybindings")
safeRequire("config.textobject-keymaps")
safeRequire("config.clipboard")

safeRequire("config.user-commands")
safeRequire("config.abbreviations")

--------------------------------------------------------------------------------
