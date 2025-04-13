return {
	"neovim/nvim-lspconfig",
	lazy = false,
	event = "BufReadPre",
	config = function()
		local myServerConfigs = require("config.lsp-servers").serverConfigs
		for server, config in pairs(myServerConfigs) do
			vim.lsp.config(server, config)
			-- require("lspconfig")[server].setup(config)
		end
	end,
}
