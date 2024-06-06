local plugins = {
	{
		"folke/noice.nvim",
		dependencies = "MunifTanjim/nui.nvim",
		opts = {
			presets = { command_palette = true },
		},
	},
}

vim.keymap.set("c", "<BS>", function()
	if vim.fn.getcmdline() ~= "" then return "<BS>" end
end, { expr = true, desc = "<BS> does not leave cmdline" })
--------------------------------------------------------------------------------

for _, name in ipairs { "config", "data", "state", "cache" } do
	vim.env[("XDG_%s_HOME"):format(name:upper())] = "/tmp/nvim-debug/" .. name
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) == nil then
	local lazyrepo = "https://github.com/folke/lazy.nvim"
	vim.system({ "git", "clone", "--filter=blob:none", lazyrepo, "--branch=stable", lazypath }):wait()
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup(plugins)

--------------------------------------------------------------------------------
