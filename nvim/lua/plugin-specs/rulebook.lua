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
		{
			"<leader>cp",
			function() require("rulebook").prettifyError() end,
			mode = { "n", "x" },
			ft = { "javascript", "typescript" },
			desc = " Prettify error",
		},
	},
	opts = {
		ruleDocs = {
			fallback = "https://chatgpt.com/?q=Explain%20the%20following%20diagnostic%20error%3A%20%s",
		},
		suppressFormatter = {
			-- use `biome` instead of `prettier`
			javascript = {
				ignoreBlock = "// biome-ignore format: expl",
				ignoreRange = { "// biome-ignore-start format: expl", "// biome-ignore-end format: -" },
			},
			typescript = {
				ignoreBlock = "// biome-ignore format: expl",
				ignoreRange = { "// biome-ignore-start format: expl", "// biome-ignore-end format: -" },
			},
			css = {
				ignoreBlock = "/* biome-ignore format: expl */",
				-- stylua: ignore
				ignoreRange = { "/* biome-ignore-start format: expl */", "/* biome-ignore-end format: - */" },
			},
		},
	},
}
