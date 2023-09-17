local keymap = vim.keymap.set
local u = require("config.utils")
local abbr = vim.cmd.inoreabbrev

--------------------------------------------------------------------------------

-- extra trailing chars
keymap("n", "<leader>|", "mzA |<Esc>`z", { desc = "which_key_ignore", buffer = true })
keymap("n", "<leader>\\", "mzA \\<Esc>`z", { desc = "which_key_ignore", buffer = true })

-- habit from writing too much js or lua
abbr("<buffer> // #")
abbr("<buffer> -- #")

u.applyTemplateIfEmptyFile("zsh")

-- pipe textobj
keymap(
	{ "o", "x" },
	"i|",
	"<cmd>lua require('various-textobjs').shellPipe(true)<CR>",
	{ desc = "󱡔 inner shellPipe textobj", buffer = true }
)
keymap(
	{ "o", "x" },
	"a|",
	"<cmd>lua require('various-textobjs').shellPipe(false)<CR>",
	{ desc = "󱡔 outer shellPipe textobj", buffer = true }
)

--------------------------------------------------------------------------------
