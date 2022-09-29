-- INFO: file should *not* be named "packer.lua", since then `require("packer")`
-- is ambigious

--------------------------------------------------------------------------------

-- auto-install packer if not installed https://github.com/wbthomason/packer.nvim#bootstrapping
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	print("Packer not installed. Installing...")
	vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
	vim.cmd [[packadd packer.nvim]]
end

-- Protected call to make sure that packer is installed
local status_ok, packer = pcall(require, "packer")
if (not status_ok) then return end

-- load all plugins
require("plugin-list")
packer.startup(PluginList)

-- https://github.com/wbthomason/packer.nvim#performing-plugin-management-operations
packer.install() -- auto-install missing plugins
packer.clean() -- remove unused plugins

-- Keymaps: Update [P]lugins
vim.keymap.set("n", "<leader>P", ":PackerStatus<CR>")
vim.keymap.set("n", "<leader>p", function()
	package.loaded["plugin-list"] = nil -- empty the cache for lua
	require("plugin-list")
	local packer = require("packer")
	packer.startup(PluginList)
	packer.sync()

end)


