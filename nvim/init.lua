-- If nvim was opened w/o argument, re-open the first oldfile that exists
vim.defer_fn(function()
	if vim.fn.argc() > 0 then return end
	for _, file in ipairs(vim.v.oldfiles) do
		if vim.loop.fs_stat(file) and not file:find("/COMMIT_EDITMSG$") then
			vim.cmd.edit(file)
			return
		end
	end
end, 1)

--------------------------------------------------------------------------------

vim.g.mapleader = ","
vim.g.maplocalleader = ";"

vim.g.borderStyle = "single" ---@type "single"|"double"|"rounded"|"solid"|"none"

vim.g.linterConfigFolder = os.getenv("HOME") .. "/.config/+ linter-configs/"

--------------------------------------------------------------------------------

---Try to require the module, and do not error out when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, errMsg = pcall(require, module)
	if not success then
		local msg = ("Error loading %s\n%s"):format(module, errMsg)
		-- defer so notification plugins are loaded before
		vim.defer_fn(function() vim.notify(msg, vim.log.levels.ERROR) end, 1)
	end
end

safeRequire("config.lazy")
safeRequire("config.neovide-settings")
safeRequire("config.theme-customization")
safeRequire("config.options-and-autocmds")

safeRequire("config.keybindings")
safeRequire("config.leader-keybindings")

safeRequire("config.lsp-and-diagnostics")
safeRequire("config.spellfixes")

--------------------------------------------------------------------------------

if vim.fn.has("nvim-0.10") == 1 then vim.notify("TODO version 0.10.md") end
