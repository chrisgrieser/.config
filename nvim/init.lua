-- If nvim was opened w/o argument, re-open the first oldfile that exists
vim.defer_fn(function()
	if vim.fn.argc() > 0 then return end
	for _, file in ipairs(vim.v.oldfiles) do
		if vim.loop.fs_stat(file) then
			vim.cmd.edit(file)
			return
		end
	end
end, 1)

vim.g.mapleader = ","
vim.g.maplocalleader = "ä"

--------------------------------------------------------------------------------

---Try to require the module, and do not error out when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, result = pcall(require, module)
	if success then return end
	vim.defer_fn( -- defer so notification plugins are loaded before
		function() vim.notify(("Error loading %s\n%s"):format(module, result), vim.log.levels.ERROR) end,
		1
	)
end

safeRequire("config.lazy")
if vim.fn.has("gui_running") == 1 then safeRequire("config.gui-settings") end
safeRequire("config.theme-customization")
safeRequire("config.options-and-autocmds")

safeRequire("config.keybindings")
safeRequire("config.leader-keybindings")

safeRequire("config.diagnostics")
safeRequire("config.user-commands")
safeRequire("config.spellfixes")

--------------------------------------------------------------------------------

if vim.version().major == 0 and vim.version().minor >= 10 then
	vim.notify("TODO version 0.10.md")
end
