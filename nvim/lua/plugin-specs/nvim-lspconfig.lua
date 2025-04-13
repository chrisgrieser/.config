return {
	"neovim/nvim-lspconfig",

	-- no need to load the plugin, since we just want its configs, adding the
	-- plugin to the runtime is enough
	lazy = true,
	init = function()
		local lspConfigPath = require("lazy.core.config").options.root .. "/nvim-lspconfig"
		vim.opt.runtimepath:append(lspConfigPath)
	end,
}
