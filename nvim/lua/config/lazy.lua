-- https://github.com/folke/lazy.nvim#-installation

--------------------------------------------------------------------------------
-- Bootstrap Lazy.nvim plugin manager

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	}
end
vim.opt.runtimepath:prepend(lazypath)

--------------------------------------------------------------------------------
-- configure
require("lazy").setup("config/plugin-list", {
	dev = {
		-- alternative setup method https://www.reddit.com/r/neovim/comments/zk187u/how_does_everyone_segment_plugin_development_from/
		path = vim.fn.stdpath("config") .. "/my-plugins/",
	},
	ui = {
		border = borderStyle,
	},
	checker = {
		enabled = true, -- automatically check for plugin updates
		notify = false, -- get a notification when new updates are found
		frequency = 86400, -- check for updates every 24 hours
	},
})
