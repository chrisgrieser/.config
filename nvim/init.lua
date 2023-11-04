---Try to require the module, and do not error out when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, result = pcall(require, module)
	if success then return end
	vim.defer_fn( -- defer to so notification plugins are loaded before
		function() vim.notify(("Error loading %s\n%s"):format(module, result), vim.log.levels.ERROR) end,
		1
	)
end

-- If nvim was opened w/o argument, re-open the last file.
-- If that files does not exist, open last existing oldfile.
local function reOpenLastFile()
	if vim.fn.argc() ~= 0 then return end

	vim.defer_fn(function()
		local function fileDoesNotExist(file) return vim.loop.fs_stat(file) == nil end
		local lastFile = vim.api.nvim_get_mark("0", {})[4]
		local i = 0
		while fileDoesNotExist(lastFile) and i < #vim.v.oldfiles do
			i = i + 1
			lastFile = vim.v.oldfiles[i]
		end
		if lastFile == "" then return end
		vim.cmd.edit(lastFile)
	end, 1)
end
reOpenLastFile()

--------------------------------------------------------------------------------

vim.g.mapleader = ","
vim.g.maplocalleader = "ö"

--------------------------------------------------------------------------------

safeRequire("config.lazy")
if vim.fn.has("gui_running") == 1 then safeRequire("config.gui-settings") end
safeRequire("config.theme-customization")
safeRequire("config.options-and-autocmds")

safeRequire("config.keybindings")
safeRequire("config.leader-keybindings")

safeRequire("config.diagnostics")
safeRequire("config.user-commands")
safeRequire("config.abbreviations")

--------------------------------------------------------------------------------

if vim.version().major == 0 and vim.version().minor >= 10 then
	local todo = [[
		# nvim 0.10
		- satellite.nvim can now be updated.
		- change event trigger for symbols-usage
		- biome lspconfig https://github.com/neovim/nvim-lspconfig/issues/2807
		- yaml-ls dynamic formatting as well?
		- vim.system
		- vim.lsp.getclient
		- vim.uv instead of vim.loop
		- ftAbbr & abbreviations.lua: vim.keymap.set('ia', lhs, rhs, { buffer = true })
		- inlay hints setup: https://www.reddit.com/r/neovim/comments/16tmzkh/comment/k2gpy16/?context=3
		- change lsp-signature to inline hint
		- vim.snippet https://www.reddit.com/r/neovim/comments/17cwptz/comment/k5uoswd/?utm_source=share&utm_medium=web2x&context=3
	]]
	vim.notify(todo)
end
