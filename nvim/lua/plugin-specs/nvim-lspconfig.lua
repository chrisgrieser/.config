return {
	"neovim/nvim-lspconfig",

	-- No need to load the plugin—since we just want its configs, adding the
	-- it to the `runtimepath` is enough.
	lazy = true,
	init = function()
		local lspConfigPath = require("lazy.core.config").options.root .. "/nvim-lspconfig"
		vim.opt.runtimepath:append(lspConfigPath)
	end,
}
