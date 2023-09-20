for _, name in ipairs { "config", "data", "state", "cache" } do
	vim.env[("XDG_%s_HOME"):format(name:upper())] =  "/tmp/nvim-debug/" .. name
end

--------------------------------------------------------------------------------

local plugins = {
	{ "windwp/nvim-autopairs", opts = true }
}

--------------------------------------------------------------------------------


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	}
end
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup(plugins)

--------------------------------------------------------------------------------

-- basic appearance settings to not make me crazy
vim.opt.swapfile = false -- disable prompt when things crash
vim.cmd.colorscheme("habamax")
vim.opt.guifont = "JetBrainsMonoNL Nerd Font:h25.2"
vim.opt.signcolumn = "yes:1"

--------------------------------------------------------------------------------
