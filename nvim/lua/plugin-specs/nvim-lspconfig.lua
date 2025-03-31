return {
	"neovim/nvim-lspconfig",
	event = "BufReadPre",
	config = function()
		local capabilities = vim.lsp.protocol.make_client_capabilities()

		-- completion capabilities (blink.cmp)
		-- https://cmp.saghen.dev/installation.html#lsp-capabilities
		local blinkInstalled, blink = pcall(require, "blink.cmp")
		if blinkInstalled then capabilities = blink.get_lsp_capabilities() end

		local myServerConfigs = require("config.lsp-servers").serverConfigs
		for lsp, config in pairs(myServerConfigs) do
			config.capabilities = capabilities
			require("lspconfig")[lsp].setup(config)
		end
	end,
}
