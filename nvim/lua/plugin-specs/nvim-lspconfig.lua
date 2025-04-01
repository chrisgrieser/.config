return {
	"neovim/nvim-lspconfig",
	event = "BufReadPre",
	config = function()
		local blinkInstalled, blink = pcall(require, "blink.cmp")

		local myServerConfigs = require("config.lsp-servers").serverConfigs
		for server, config in pairs(myServerConfigs) do
			-- completion capabilities (blink.cmp)
			-- https://cmp.saghen.dev/installation.html#lsp-capabilities
			if blinkInstalled then
				config.capabilities = blink.get_lsp_capabilities(config.capabilities)
			end

			require("lspconfig")[server].setup(config)
		end
	end,
}
