---try to require the module, and do not error out when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, _ = pcall(require, module)
	if not success then
		vim.cmd(('echohl Error | echomsg "Error loading %s" | echohl None'):format(module))
	end
end

-- if opened without argument, re-open the last file
local function reOpenLastFile()
	if vim.fn.argc() ~= 0 then return end
	vim.defer_fn(function()
		if vim.bo.filetype == "lazy" then return end -- lazy auto-installs
		pcall(vim.cmd.normal, { "'0", bang = true })
		pcall(vim.cmd.bwipeout, "#") -- do not leave empty file
	end, 1)
end

--------------------------------------------------------------------------------

vim.g.mapleader = ","
vim.g.maplocalleader = "ö"
vim.loader.enable() -- TODO will be nvim default in later versions

safeRequire("config.lazy")
if vim.fn.has("gui_running") == 1 then safeRequire("config.gui-settings") end
safeRequire("config.theme-customization")
safeRequire("config.options-and-autocmds")

reOpenLastFile()

safeRequire("config.keybindings")
safeRequire("config.leader-keybindings")
safeRequire("config.textobject-keymaps")

safeRequire("config.user-commands")
safeRequire("config.abbreviations")

safeRequire("funcs.pulling-strings")
