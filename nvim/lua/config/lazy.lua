--------------------------------------------------------------------------------
-- Bootstrap Lazy.nvim plugin manager https://github.com/folke/lazy.nvim#-installation
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
-- config https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require("lazy").setup("config/plugin-list", {
	defaults = {
		-- version = "*", -- install the latest *stable* versions of plugins
	},
	dev = {
		-- alternative setup method https://www.reddit.com/r/neovim/comments/zk187u/how_does_everyone_segment_plugin_development_from/
		path = vim.fn.stdpath("config") .. "/my-plugins/",
		pattern = {"chrisgrieser"} -- these plugins will always be regarded as local
	},
	ui = {
		border = borderStyle,
		size = { width = 0.9, height = 0.95 }, -- a number <1 is a percentage., >1 is a fixed size
	},
	checker = {
		enabled = true, -- automatically check for plugin updates
		notify = false, -- get a notification when new updates are found
		frequency = 86400, -- check for updates every 24 hours
	},
	change_detection = {
		notify = false,
	},
	performance = {
		rtp = { -- plugins names to disable
			disabled_plugins = {},
		},
	},
})
