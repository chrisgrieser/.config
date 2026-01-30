return {
	"BlinkResearchLabs/blink-edit.nvim",
	event = "InsertEnter",
	enabled = false, -- https://github.com/BlinkResearchLabs/blink-edit.nvim/issues/1
	opts = {
		llm = {
			provider = "sweep",
			backend = "openai",
			url = "http://localhost:8000",
			model = "sweep",
		},
	},
}

