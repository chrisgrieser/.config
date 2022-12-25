require("config/utils")
--------------------------------------------------------------------------------

-- TABNINE
-- INFO also requires setup in cmp config
require("cmp_tabnine.config"):setup { -- yes, requires a ":", not "."
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
	callback = function() require("cmp_tabnine"):prefetch(expand("%:p")) end,
})

--------------------------------------------------------------------------------
-- Neural
-- INFO openai_api_key defined in zshenv but there read from outside of dotfiles
keymap("x", "ga", ":NeuralCode complete<CR>")
require("neural").setup {
	mappings = {
		swift = nil,
		prompt = "gA",
	},
	open_ai = {
		api_key = vim.env.OPENAI_API_KEY, -- not committed, defined in config/private-settings.lua outside of repo
		max_tokens = 1000,
		temperature = 0.1,
		presence_penalty = 0.5,
		frequency_penalty = 0.5,
	},
	ui = { icon = "ﮧ" },
}

--------------------------------------------------------------------------------
-- ChatGPT

keymap("n", "ga", ":ChatGPT<CR>", { desc = "ChatGPT Prompt" })
-- keymap("x", "ga", ":ChatGPTEditWithInstructions<CR>", { desc = "ChatGPT Edit with Instruction" })
require("chatgpt").setup {
	welcome_message = "",
	question_sign = "",
	answer_sign = "ﮧ",
	max_line_length = 80,
	keymaps = {
		close = "<Esc>", -- removes ability to use normal mode
		yank_last = "<D-c>",
		scroll_up = "<S-Up>",
		scroll_down = "<S-Down>",
	},
	chat_window = {
		border = { style = borderStyle },
	},
	chat_input = {
		prompt = " > ",
		border = { style = borderStyle },
	},
}
