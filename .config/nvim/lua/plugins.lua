-- auto-install packer if not installed https://github.com/wbthomason/packer.nvim#bootstrapping
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
	if fn.empty(fn.glob(install_path)) > 0 then
		print("Packer not installed. Installing...")
		fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
		vim.cmd [[packadd packer.nvim]]
		return true
	end
	return false
end

local packer_bootstrap = ensure_packer()

--------------------------------------------------------------------------------
-- re-sync packer if this file changes -> https://www.reddit.com/r/neovim/comments/vqjz87/comment/ievd4tx/?utm_source=share&utm_medium=web2x&context=3
local group = vim.api.nvim_create_augroup("packer_user_config", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	command = "source <afile> | PackerSync",
	pattern = "plugins.lua", -- the name of your plugins file
	group = group,
})

--------------------------------------------------------------------------------

return require('packer').startup(function(use)
	use 'wbthomason/packer.nvim' -- packer manages itself

	-- Appearance
	use 'folke/tokyonight.nvim' -- color scheme
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides

	-- Utility
	use 'farmergreg/vim-lastplace' -- remember cursor position

	-- Editing
	use 'tpope/vim-commentary'
	use 'tpope/vim-surround'
	use 'michaeljsmith/vim-indent-object'

	-- https://github.com/wbthomason/packer.nvim#performing-plugin-management-operations
	if packer_bootstrap then
		require('packer').sync() -- install, sync & update plugins on bootstraping
	else
		require('packer').install() -- auto-install missing plugins
	end
end)


