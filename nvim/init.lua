-- If nvim was opened w/o argument, re-open the first oldfile that exists
vim.defer_fn(function()
	if vim.fn.argc() > 0 then return end
	vim.cmd.edit(vim.v.oldfiles[1])
end, 1)

vim.g.mapleader = ","
vim.g.maplocalleader = "ö"

--------------------------------------------------------------------------------

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
