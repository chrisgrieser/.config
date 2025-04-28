return {
	"chrisgrieser/nvim-rulebook",
	keys = {
		{ "<leader>cl", function() require("rulebook").lookupRule() end, desc = " Lookup rule" },
		{
			"<leader>cc",
			function() require("rulebook").ignoreRule() end,
			desc = " Comment ignore",
		},
		{
			"<leader>cy",
			function() require("rulebook").yankDiagnosticCode() end,
			desc = "󰅍 Yank diagnostic code",
		},
		{
			"<leader>cf",
			function() require("rulebook").suppressFormatter() end,
			mode = { "n", "x" },
			desc = "󰉿 Formatter suppress",
		},
	},
	opts = {
		ruleDocs = {
			fallback = "https://chatgpt.com/?q=Explain%20the%20following%20diagnostic%20error%3A%20%s"
		},
		suppressFormatter = {
			-- use `biome` instead of `prettier`
			javascript = { ignoreBlock = "// biome-ignore format: expl" },
			typescript = { ignoreBlock = "// biome-ignore format: expl" },
			css = { ignoreBlock = "/* biome-ignore format: expl */" },
		},
	},
}
