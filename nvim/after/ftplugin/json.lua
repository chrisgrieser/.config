local keymap = require("config.utils").bufKeymap

keymap(
	"n",
	"<leader>fp",
	"<cmd>%! yq --output-format=json --prettyPrint<CR>",
	{ desc = " Prettify Buffer" }
)

keymap(
	"n",
	"<leader>fm",
	"<cmd>%! yq --output-format=json --indent=0<CR>",
	{ desc = " Minify Buffer" }
)
