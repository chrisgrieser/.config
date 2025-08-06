---@module "lazy.types"
---@type LazyPluginSpec
return {
	"neovim/nvim-lspconfig",

	-- No need to load the plugin—since we just want its configs, adding the
	-- it to the `runtimepath` is enough.
	lazy = true,
	init = function()
		local lspConfigPath = require("lazy.core.config").options.root .. "/nvim-lspconfig"

		-- INFO `prepend` ensures it is loaded before the user's LSP configs, so
		-- that the user's configs override nvim-lspconfig.
		vim.opt.runtimepath:prepend(lspConfigPath)
	end,
}
