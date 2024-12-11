return {
	"chrisgrieser/nvim-lsp-endhints",
	event = "LspAttach",
	opts = {},
	keys = {
		{ "<leader>oh", function() require("lsp-endhints").toggle() end, desc = "󰑀 Endhints" },
	},
}
