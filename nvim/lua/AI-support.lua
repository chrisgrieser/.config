require("utils")
--------------------------------------------------------------------------------

-- TABNINE
-- INFO also requires setup in cmp config
require("cmp_tabnine.config"):setup {-- yes, requires a ":", not "."
	max_lines = 1000,
	max_num_results = 20,
	run_on_every_keystroke = true,
	snippet_placeholder = "…",
	show_prediction_strength = true,
}

-- automatically prefetch completions for the buffer
augroup("prefetchTabNine", {})
autocmd("BufRead", {
	group = "prefetchTabNine",
	callback = function() require("cmp_tabnine"):prefetch(fn.expand("%:p")) end
})

--------------------------------------------------------------------------------

-- ai.vim
g.ai_context_before = 10 -- lines to consider without prompt or selection
g.ai_context_after = 10
require("private-settings") -- API key symlinked and kept out of the dotfile repo

g.ai_no_mappings = true -- no default mappings
keymap("n", "ga", cmd.AI, {desc = "Run OpenAI Completion"})
keymap("x", "ga", ":AI ", {desc = "Run OpenAI Completion with instruction on selection"})

--------------------------------------------------------------------------------

-- ChatGPT
require("private-settings") -- API key symlinked and kept out of the dotfile repo
keymap({"n", "x"}, "gA", ":ChatGPT<CR>", {desc = "ChatGPT Prompt"})
require("chatgpt").setup {
	welcome_message = "",
	question_sign = "",
	answer_sign = "ﮧ",
	max_line_length = 80,
	chat_layout = {
		relative = "editor",
		position = "50%",
		size = {
			height = "80%",
			width = "80%",
		},
	},
	chat_window = {
		border = { style = borderStyle },
	},
	chat_input = {
		prompt = " > ",
		border = { style = borderStyle },
	},
	openai_params = {
		model = "text-davinci-003",
		frequency_penalty = 0,
		presence_penalty = 0,
		max_tokens = 300,
		temperature = 0,
		top_p = 1,
		n = 1,
	},
}
