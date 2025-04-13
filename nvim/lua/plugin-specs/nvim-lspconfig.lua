return {
	"neovim/nvim-lspconfig",
	event = "BufReadPre",
	config = function()
		local myServerConfigs = require("config.lsp-servers").serverConfigs
		for server, config in pairs(myServerConfigs) do
			require("lspconfig")[server].setup(config)
		end
	end,
}
