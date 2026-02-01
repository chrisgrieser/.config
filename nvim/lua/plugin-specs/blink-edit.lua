-- 1. download https://huggingface.co/sweepai/sweep-next-edit-1.5B
-- 2. run via `llama-server --model sweep-next-edit-1.5b.q8_0.v2.gguf --port 8000`
-- 3. check via `curl http://localhost:8000/v1/models | jq` the model exposed
-- 4. insert that model at `opts.llm.model`
--------------------------------------------------------------------------------

return {
	"BlinkResearchLabs/blink-edit.nvim",
	lazy = false,
	enabled = false,
	opts = {
		llm = {
			provider = "sweep",
			backend = "openai",
			url = "http://localhost:8000",
			model = "sweep-next-edit-1.5b.q8_0.v2.gguf",
		},
	},
}

