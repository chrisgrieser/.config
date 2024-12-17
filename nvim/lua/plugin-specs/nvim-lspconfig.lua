return {
	"neovim/nvim-lspconfig",
	event = "BufReadPre",
	config = function()
		-- Enable completion-related capabilities (blink.cmp)
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- enabled folding (nvim-ufo)
		capabilities.textDocument.foldingRange =
			{ dynamicRegistration = false, lineFoldingOnly = true }

		local myServerConfigs = require("config.lsp-servers").serverConfigs
		for lsp, config in pairs(myServerConfigs) do
			config.capabilities = capabilities
			require("lspconfig")[lsp].setup(config)
		end
	end,
}

