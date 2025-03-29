return {
	"neovim/nvim-lspconfig",
	event = "BufReadPre",
	keys = {
		{ "<leader>ol", vim.cmd.LspRestart, desc = "󰑓 LSP restart" },
	},
	config = function()
		local capabilities = vim.lsp.protocol.make_client_capabilities()

		-- completion capabilities (blink.cmp)
		-- https://cmp.saghen.dev/installation.html#lsp-capabilities
		local blinkInstalled, blink = pcall(require, "blink.cmp")
		if blinkInstalled then capabilities = blink.get_lsp_capabilities() end

		-- folding capabilities (nvim-ufo)
		local ufoInstalled = pcall(require, "ufo")
		if ufoInstalled then
			capabilities.textDocument.foldingRange =
				{ dynamicRegistration = false, lineFoldingOnly = true }
		end

		local myServerConfigs = require("config.lsp-servers").serverConfigs
		for lsp, config in pairs(myServerConfigs) do
			config.capabilities = capabilities
			require("lspconfig")[lsp].setup(config)
		end
	end,
}
