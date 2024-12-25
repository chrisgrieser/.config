return {
	"chrisgrieser/nvim-rulebook",
	keys = {
		{ "<leader>cl", function() require("rulebook").lookupRule() end, desc = " Lookup rule" },
		{
			"<leader>cg",
			function() require("rulebook").ignoreRule() end,
			desc = "󰅜 I[g]nore rule",
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
			desc = "󰉿 Suppress formatter",
		},
	},
	opts = {
		suppressFormatter = {
			-- use `biome` instead of `prettier`
			javascript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
			typescript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
			css = { location = "prevLine", ignoreBlock = "/* biome-ignore format: expl */" },
		},
	},
}
