-- PACKER SETUP

-- ensure that packer is installed https://bryankegley.me/posts/nvim-getting-started/
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	vim.notify("Packer not installed. Installing Packer...", vim.log.levels.INFO)
	vim.cmd('!git clone --depth=1 https://github.com/wbthomason/packer.nvim '..install_path)
end
vim.cmd('packadd packer.nvim')
local packer = require('packer')
local util = require('packer.util')
packer.init({
	package_root = util.join_paths(vim.fn.stdpath('data'), 'site', 'pack')
})

--------------------------------------------------------------------------------

packer.startup(function (use)

	use 'wbthomason/packer.nvim' -- packer manages itself

	use 'folke/tokyonight.nvim' -- color scheme
end )


