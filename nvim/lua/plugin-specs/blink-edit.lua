return {
	"BlinkResearchLabs/blink-edit.nvim",
	event = "InsertEnter",
	opts = {
		llm = {
			provider = "sweep",
			backend = "openai",
			url = "http://localhost:8000",
			model = "sweep",
		},
	},
}

