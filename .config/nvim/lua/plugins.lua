--------------------------------------------------------------------------------
-- PACKER SETUP

-- https://bryankegley.me/posts/nvim-getting-started/

-- ensure that packer is installed
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.api.nvim_command('!git clone --depth=1 https://github.com/wbthomason/packer.nvim '..install_path)
	vim.api.nvim_command 'packadd packer.nvim'
end
vim.cmd('packadd packer.nvim')
local packer = require('packer')
local util = require('packer.util')
packer.init({
	package_root = util.join_paths(vim.fn.stdpath('data'), 'site', 'pack')
})

--------------------------------------------------------------------------------

packer.startup(function (use)
	use 'folke/tokyonight.nvim'
end )


