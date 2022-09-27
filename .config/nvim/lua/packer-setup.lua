require("utils")
--------------------------------------------------------------------------------

-- auto-install packer if not installed https://github.com/wbthomason/packer.nvim#bootstrapping
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	print("Packer not installed. Installing...")
	fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
	cmd [[packadd packer.nvim]]
end

--------------------------------------------------------------------------------
-- Protected call to make sure that packer is installed
local status_ok, packer = pcall(require, "packer")
if (not status_ok) then return end

--------------------------------------------------------------------------------
-- load all plugins
require("plugin-list")
packer.startup(pluginList)

-- https://github.com/wbthomason/packer.nvim#performing-plugin-management-operations
packer.install() -- auto-install missing plugins
packer.clean() -- remove unused plugins

--------------------------------------------------------------------------------
-- Keymaps: Update [P]lugins
keymap("n", "<leader>P", ":PackerStatus<CR>")
keymap("n", "<leader>p", function()
	package.loaded["plugin-list"] = nil -- empty the cache for lua
	require("plugin-list")
	packer.startup(pluginList)
	packer.sync()
end)


