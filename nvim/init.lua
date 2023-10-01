---Try to require the module, and do not error out when one of them cannot be
---loaded, but do notify if there was an error.
---@param module string module to load
local function safeRequire(module)
	local success, _ = pcall(require, module)
	if success then return end
	vim.cmd.echomsg(("'Error loading %s'"):format(module))
end

-- If nvim was opened w/o argument, re-open the last file.
-- If that files does not exist, open last existing oldfile.
local function reOpenLastFile()
	if vim.fn.argc() ~= 0 then return end
	if vim.bo.filetype == "lazy" then vim.cmd.close() end

	local lastFileExist = vim.loop.fs_stat(vim.api.nvim_get_mark("0", {})[4]) ~= nil
	if lastFileExist then
		vim.cmd.normal { "'0", bang = true }
		pcall(vim.cmd.bwipeout, "#") -- remove leftover new buffer
	else
		local i = 0
		local oldfile
		repeat
			i = i + 1
			if i > #vim.v.oldfiles then return end
			oldfile = vim.v.oldfiles[i]
			local fileExists = vim.loop.fs_stat(oldfile) ~= nil
		until fileExists
		vim.cmd.edit(oldfile)
	end
end
vim.defer_fn(reOpenLastFile, 1) -- after options, so correct shada file is read

--------------------------------------------------------------------------------

vim.g.mapleader = ","
vim.g.maplocalleader = "ö"

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
		- vim.system
		- vim.lsp.getclient
		- vim.uv instead of vim.loop
		- ftAbbr & abbreviations.lua: vim.keymap.set('ia', lhs, rhs, { buffer = true })
		- inlay hints setup: https://www.reddit.com/r/neovim/comments/16tmzkh/comment/k2gpy16/?context=3
		- change lsp-signature inline hint
	]]
	vim.notify(todo)
end
