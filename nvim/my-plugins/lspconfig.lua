vim.pack.add({
	"https://github.com/neovim/nvim-lspconfig",
}, { load = function() end }) -- do not add package, we just need its runtimepath

-- INFO `prepend` ensures it is loaded before the user's LSP configs, so
-- that the user's configs override nvim-lspconfig.
local lspConfigPath = vim.fn.stdpath("data") .. "/site/pack/opts" .. "/nvim-lspconfig"
vim.opt.runtimepath:prepend(lspConfigPath)
--------------------------------------------------------------------------------
