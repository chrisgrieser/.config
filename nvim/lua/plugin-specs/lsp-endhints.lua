return {
	"chrisgrieser/nvim-lsp-endhints",
	event = "LspAttach",
	keys = {
		{ "<leader>oh", function() require("lsp-endhints").toggle() end, desc = "󰑀 Endhints" },
	},
	opts = {
		label = {
			sameKindSeparator = " ",
		}
	},
}
