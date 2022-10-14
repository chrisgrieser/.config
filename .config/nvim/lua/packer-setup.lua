-- INFO: file should *not* be named "packer.lua", since then `require("packer")`
-- is ambigious

--------------------------------------------------------------------------------

-- auto-install packer if not installed https://github.com/wbthomason/packer.nvim#bootstrapping
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then ---@diagnostic disable-line: missing-parameter
	print("Packer not installed. Installing...")
	vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
	vim.cmd [[packadd packer.nvim]]
end

-- Protected call to make sure that packer is installed
local status_ok, packer = pcall(require, "packer")
if (not status_ok) then return end

-- Load plugins and display packer as popup
require("plugin-list")
packer.startup({
	PluginList,
	config = {
		display = {
			open_fn = function()
				return require('packer.util').float{border = borderStyle}
			end
		}
	}
})

packer.install() -- auto-install missing plugins
packer.clean() -- remove unused plugins

