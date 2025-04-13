return {
	"neovim/nvim-lspconfig",

	-- no need to load the plugin, just need to add its configs to the runtime
	lazy = true,
	init = function()
		local lspConfigPath = require("lazy.core.config").options.root .. "/nvim-lspconfig"
		vim.opt.runtimepath:prepend(lspConfigPath)
	end,
}
