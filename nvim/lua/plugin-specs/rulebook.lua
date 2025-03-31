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
		ignoreComments = {
			["Lua Diagnostics."] = { -- Lua LSP
				comment = "---@diagnostic disable-next-line: %s",
				location = "prevLine",
				multiRuleIgnore = true,
			},
		},
		suppressFormatter = {
			-- use `biome` instead of `prettier`
			javascript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
			typescript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
			css = { location = "prevLine", ignoreBlock = "/* biome-ignore format: expl */" },
		},
	},
}
