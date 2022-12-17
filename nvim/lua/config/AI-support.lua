require("config/utils")
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

-- ChatGPT
require("private-settings") -- API key symlinked and kept out of the dotfile repo
keymap("n", "ga", ":ChatGPT<CR>", {desc = "ChatGPT Prompt"})
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
	keymaps = {
		close = "<Esc>", -- removes ability to use normal mode
		yank_last = "<D-c>",
		scroll_up = "<S-Up>",
		scroll_down = "<S-Down>",
	},
	chat_window = {
		filetype = "chatgpt",
		border = {style = borderStyle},
	},
	chat_input = {
		prompt = " > ",
		border = {style = borderStyle},
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
