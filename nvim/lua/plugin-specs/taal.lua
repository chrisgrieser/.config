return {
	"bennorichters/taal.nvim",
	init = require("config.utils").loadOpenAiKey,
	keys = {
		{ "zp", "<Cmd>TaalGrammar<CR>", desc = "󰓆 Proofread" },
		{ "za", "<Cmd>TaalApplySuggestion<CR>", desc = "󰓆 Accept proofread" },
	},
	dependencies = "nvim-lua/plenary.nvim",
	opts = {
		adapter = "openai_responses",
		model = "gpt-4.1-mini", -- gpt-5-mini not working
	},
}
