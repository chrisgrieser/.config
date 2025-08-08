---@module "lazy.types"
---@type LazyPluginSpec
return {
	"chrisgrieser/nvim-lsp-endhints",
	event = "LspAttach",
	keys = {
		{ "<leader>oh", function() require("lsp-endhints").toggle() end, desc = "󰑀 Endhints" },
	},
	config = function(_, opts)
		-- FIX for emmylua_ls not loading on startup
		vim.defer_fn(function() require("lsp-endhints").setup(opts) end, 100)
	end,
	opts = {
		label = {
			sameKindSeparator = " ",
		},
	},
}
