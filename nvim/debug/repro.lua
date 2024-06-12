local plugins = {
	"folke/noice.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
	opts = true,
}

--------------------------------------------------------------------------------
local reproLocation = "/tmp/nvim-debug"
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- use existing install
for _, name in ipairs { "config", "data", "state", "cache" } do
	vim.env[("XDG_%s_HOME"):format(name:upper())] = reproLocation .. "/" .. name
end
if vim.uv.fs_stat(lazypath) == nil then
	local lazyrepo = "https://github.com/folke/lazy.nvim"
	vim.system({ "git", "clone", "--filter=blob:none", lazyrepo, "--branch=stable", lazypath }):wait()
end
vim.opt.runtimepath:prepend(lazypath)
require("lazy").setup(plugins)
