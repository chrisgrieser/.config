local plugins = {
	{
		"chrisgrieser/nvim-recorder",
		event = "BufRead",
		opts = {
			mapping = {
				startStopRecording = "m",
				playMacro = "M",
			},
		},
	},
}

--------------------------------------------------------------------------------

for _, name in ipairs { "config", "data", "state", "cache" } do
	vim.env[("XDG_%s_HOME"):format(name:upper())] = "/tmp/nvim-debug/" .. name
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim"
	vim.system { "git", "clone", "--filter=blob:none", lazyrepo, "--branch=stable", lazypath }
end
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup(plugins)

--------------------------------------------------------------------------------

-- basic appearance settings to not be annoyed
vim.opt.swapfile = false -- disable prompt when things crash
vim.cmd.colorscheme("habamax")
vim.opt.guifont = "JetBrainsMonoNL NF" .. ":h26"
vim.opt.signcolumn = "yes:1"
